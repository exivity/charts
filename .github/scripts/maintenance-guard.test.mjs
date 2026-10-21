import { test } from "node:test";
import assert from "node:assert/strict";
import * as fs from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { runInNewContext } from "node:vm";

const repo = "charts";
const guardPath = fileURLToPath(
  new URL("./maintenance-guard.mjs", import.meta.url)
);
const source = fs
  .readFileSync(guardPath, "utf8")
  .replace(/^import[\s\S]*?from ["']node:[^"']+["'];?\r?\n/gm, "");
assert.doesNotMatch(source, /^import/m);

function execute(planError = false) {
  const root = fs.mkdtempSync(join(tmpdir(), "large-plan-guard-"));
  const marker = join(root, ".maintenance-release.json");
  const output = join(root, "output");
  const envFile = join(root, "env");
  const revision = "a".repeat(40);
  const hash = "b".repeat(64);
  const plan = JSON.stringify({
    verification: { hash },
    padding: "x".repeat(2 * 1024 * 1024),
  });
  fs.writeFileSync(
    marker,
    JSON.stringify({ version: "v3.39.3", planRef: "maintenance-plan-v3.39.3" })
  );
  const reads = [];
  let verified = false;
  const execFileSync = (command, args, options = {}) => {
    if (command === "git") return revision;
    if (command === process.execPath) {
      assert.deepEqual(Array.from(args).slice(1), [
        "guard",
        repo,
        revision,
        "v3.39.3",
      ]);
      verified = true;
      return "";
    }
    assert.equal(command, "gh");
    assert.equal(args[0], "api");
    const path = args[1];
    if (path.includes("/commits/")) return JSON.stringify({ sha: revision });
    const raw = args.includes("Accept: application/vnd.github.raw+json");
    reads.push({ path, raw });
    let result;
    if (path.includes("/contents/.github/maintenance/")) {
      const content = "// verifier fixture\n";
      result = raw
        ? content
        : JSON.stringify({
            encoding: "base64",
            content: Buffer.from(content).toString("base64"),
          });
    } else {
      assert.equal(
        path,
        `repos/exivity/exivity/contents/release-plan.json?ref=${revision}`
      );
      if (planError) throw new Error("GitHub request failed: HTTP 404");
      result = raw
        ? plan
        : JSON.stringify({ encoding: "none", content: "", size: plan.length });
    }
    if (Buffer.byteLength(result) > (options.maxBuffer || 1024 * 1024)) {
      throw new Error("stdout maxBuffer exceeded");
    }
    return result;
  };
  try {
    runInNewContext(
      source,
      {
        ...fs,
        existsSync: (path) =>
          fs.existsSync(path === ".maintenance-release.json" ? marker : path),
        readFileSync: (path, ...args) =>
          fs.readFileSync(
            path === ".maintenance-release.json" ? marker : path,
            ...args
          ),
        execFileSync,
        tmpdir: () => root,
        join,
        Buffer,
        console: { log() {} },
        process: {
          argv: ["node", guardPath, repo, "v3.39.3"],
          execPath: process.execPath,
          env: {
            GITHUB_REF_TYPE: "tag",
            GITHUB_OUTPUT: output,
            GITHUB_ENV: envFile,
          },
        },
      },
      { filename: guardPath }
    );
    assert.equal(verified, true);
    assert.equal(reads.length, 5);
    assert.ok(reads.every((read) => read.raw));
    assert.match(
      fs.readFileSync(envFile, "utf8"),
      new RegExp(`MAINTENANCE_PLAN_HASH=${hash}`)
    );
    if (repo === "scaffold")
      assert.match(fs.readFileSync(envFile, "utf8"), /MANUAL_RELEASE=1/);
  } catch (error) {
    assert.equal(fs.existsSync(envFile), false);
    throw error;
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
}

test("tag guard reads a plan larger than 1 MB from the exact coordinator commit", () =>
  execute());
test("tag guard stops if GitHub cannot return the plan", () => {
  assert.throws(() => execute(true), /GitHub request failed: HTTP 404/);
});
