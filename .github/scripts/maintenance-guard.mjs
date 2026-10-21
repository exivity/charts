// Download verification code only from the immutable coordinator plan tag.
import { execFileSync } from "node:child_process";
import {
  appendFileSync,
  existsSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
const [repo, ref = process.env.GITHUB_REF_NAME] = process.argv.slice(2);
function api(path) {
  return JSON.parse(execFileSync("gh", ["api", path], { encoding: "utf8" }));
}
function file(path) {
  return execFileSync(
    "gh",
    ["api", path, "-H", "Accept: application/vnd.github.raw+json"],
    { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 },
  );
}
const markerPath = ".maintenance-release.json";
const version = ref?.startsWith("exivity-")
  ? "v" + ref.slice(8)
  : /^v\d+\.\d+\.\d+$/.test(ref)
    ? ref
    : null;
if (!existsSync(markerPath)) {
  let targetVersion = version;
  if (!targetVersion && repo === "scaffold" && existsSync("exivity.lock")) {
    targetVersion =
      "v" + JSON.parse(readFileSync("exivity.lock")).version.replace(/^v/, "");
  }
  if (
    !targetVersion &&
    repo === "charts" &&
    existsSync("charts/exivity/Chart.yaml")
  ) {
    targetVersion =
      "v" +
      readFileSync("charts/exivity/Chart.yaml", "utf8").match(
        /^version:\s*["']?([^\s"']+)/m,
      )?.[1];
  }
  if (targetVersion) {
    let tag;
    try {
      tag = api(
        `repos/exivity/exivity/git/ref/tags/maintenance-plan-${targetVersion}`,
      );
    } catch (e) {
      if (!/HTTP 404/.test(String(e.stderr))) throw e;
    }
    if (tag)
      throw Error(
        "Maintenance plan exists but this checkout has no marker. Refusing standard main-image promotion.",
      );
  }
  if (process.env.GITHUB_OUTPUT)
    appendFileSync(process.env.GITHUB_OUTPUT, "maintenance=false\n");
} else {
  const m = JSON.parse(readFileSync(markerPath));
  if (process.env.GITHUB_OUTPUT)
    appendFileSync(process.env.GITHUB_OUTPUT, "maintenance=true\n");
  const canonical = process.env.GITHUB_REF_TYPE === "tag";
  if (repo === "scaffold" && !canonical) {
    if (process.env.MANUAL_RELEASE === "1" || ref === "master")
      throw Error(
        "Maintenance installer publication requires the planned release tag",
      );
    console.log(
      "Maintenance candidate: preserve the reviewed lockfile; no canonical release upload.",
    );
  } else {
    if (version !== m.version) throw Error("Wrong maintenance release tag");
    const commit = api(`repos/exivity/exivity/commits/${m.planRef}`).sha;
    if (!/^[a-f0-9]{40}$/.test(commit)) throw Error("Invalid plan commit");
    const dir = mkdtempSync(join(tmpdir(), "maintenance-verifier-"));
    try {
      for (const name of [
        "cli.mjs",
        "plan.mjs",
        "boundary.mjs",
        "release.mjs",
      ]) {
        const contents = file(
          `repos/exivity/exivity/contents/.github/maintenance/${name}?ref=${commit}`,
        );
        writeFileSync(join(dir, name), contents);
      }
      const checkout = execFileSync("git", ["rev-parse", "HEAD"], {
        encoding: "utf8",
      }).trim();
      execFileSync(
        process.execPath,
        [join(dir, "cli.mjs"), "guard", repo, checkout, ref],
        { stdio: "inherit" },
      );
      const plan = JSON.parse(
        file(`repos/exivity/exivity/contents/release-plan.json?ref=${commit}`),
      );
      if (process.env.GITHUB_ENV) {
        appendFileSync(
          process.env.GITHUB_ENV,
          `MAINTENANCE_PLAN_HASH=${plan.verification.hash}\n`,
        );
        if (repo === "scaffold")
          appendFileSync(process.env.GITHUB_ENV, "MANUAL_RELEASE=1\n");
      }
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  }
}
