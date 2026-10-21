import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import {
  mkdtempSync,
  mkdirSync,
  writeFileSync,
  readFileSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
const HASH = "f".repeat(64),
  SHA = "b".repeat(40);
function run(state, fail = "") {
  const dir = mkdtempSync(join(tmpdir(), "maintenance-chart-publish-"));
  mkdirSync(join(dir, "bin"));
  writeFileSync(
    join(dir, ".maintenance-release.json"),
    JSON.stringify({ version: "v3.39.3" }),
  );
  const mock = `#!/usr/bin/env node
const fs = require('node:fs'), path = require('node:path');
const name = path.basename(process.argv[1]), args = process.argv.slice(2);
fs.appendFileSync('calls', JSON.stringify([name, ...args])+'\\n');
const state=process.env.STATE, fail=process.env.FAIL;
if(name==='git') { if(args.join(' ')==='rev-parse HEAD') console.log('${SHA}'); else process.exit(99); }
if(name==='gh' && args[0]==='api' && state==='new') { console.error('HTTP 404'); process.exit(1); }
if(name==='gh' && args[0]==='api' && state==='unavailable') { console.error('HTTP 503'); process.exit(1); }
if(name==='gh' && args[1]==='download') {
 const pattern=args[args.indexOf('--pattern')+1], dir=args[args.indexOf('--dir')+1];
 fs.writeFileSync(path.join(dir,pattern),pattern==='maintenance-plan.sha256' ? (state==='conflict'?'wrong':'${HASH}') : 'published archive');
}
if(name==='cr' && args[0]==='package') fs.writeFileSync('.cr-release-packages/exivity-3.39.3.tgz','new archive');
if(name==='cr' && args[0]===fail) process.exit(2);
`;
  for (const name of ["cr", "gh", "git"])
    writeFileSync(join(dir, "bin", name), mock, { mode: 0o755 });
  const result = spawnSync(
    "bash",
    [fileURLToPath(new URL("./publish-maintenance-chart.sh", import.meta.url))],
    {
      cwd: dir,
      encoding: "utf8",
      env: {
        ...process.env,
        PATH: `${join(dir, "bin")}:${process.env.PATH}`,
        STATE: state,
        FAIL: fail,
        GITHUB_REPOSITORY: "exivity/charts",
        MAINTENANCE_PLAN_HASH: HASH,
      },
    },
  );
  const calls = readFileSync(join(dir, "calls"), "utf8")
    .trim()
    .split("\n")
    .map(JSON.parse);
  const archive = (() => {
    try {
      return readFileSync(
        join(dir, ".cr-release-packages/exivity-3.39.3.tgz"),
        "utf8",
      );
    } catch {
      return null;
    }
  })();
  rmSync(dir, { recursive: true, force: true });
  return { result, calls, archive };
}
test("a tagged HEAD still publishes the exact maintenance chart without change discovery", () => {
  const { result, calls } = run("new");
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(
    calls.filter((c) => c[0] === "cr").map((c) => c[1]),
    ["package", "upload", "index"],
  );
  assert.ok(
    calls.find((c) => c[0] === "cr" && c[1] === "upload").includes(SHA),
  );
  assert.ok(
    calls.some((c) => c[0] === "gh" && c[1] === "release" && c[2] === "upload"),
  );
});
test("matching retries reindex the published archive without rebuilding or overwriting it", () => {
  const { result, calls, archive } = run("existing");
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(
    calls.filter((c) => c[0] === "cr").map((c) => c[1]),
    ["index"],
  );
  assert.equal(archive, "published archive");
  assert.ok(!calls.some((c) => c[0] === "gh" && c[2] === "upload"));
});
test("conflicting plans and API failures stop before package publication", () => {
  for (const state of ["conflict", "unavailable"]) {
    const { result, calls } = run(state);
    assert.notEqual(result.status, 0);
    assert.ok(!calls.some((c) => c[0] === "cr"));
  }
});
test("failed uploads do not publish a plan marker or update the index", () => {
  const { result, calls } = run("new", "upload");
  assert.notEqual(result.status, 0);
  assert.ok(!calls.some((c) => c[0] === "cr" && c[1] === "index"));
  assert.ok(!calls.some((c) => c[0] === "gh" && c[2] === "upload"));
});
test("an index failure remains retryable using the matching published package", () => {
  assert.notEqual(run("new", "index").result.status, 0);
  assert.equal(run("existing").result.status, 0);
});
