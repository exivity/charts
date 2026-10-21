#!/usr/bin/env bash
set -euo pipefail

# The coordinator has already tagged HEAD. Do not discover changes with
# git describe: that would compare the package with itself and publish nothing.
: "${MAINTENANCE_PLAN_HASH:?Missing verified plan hash}"
: "${GITHUB_REPOSITORY:?Missing chart repository}"
[[ "$MAINTENANCE_PLAN_HASH" =~ ^[a-f0-9]{64}$ ]]
VERSION=$(jq -r .version .maintenance-release.json)
[[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
TAG="exivity-${VERSION#v}"
PACKAGE="exivity-${VERSION#v}.tgz"
OWNER="${GITHUB_REPOSITORY%/*}"
REPOSITORY="${GITHUB_REPOSITORY#*/}"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
mkdir -p .cr-release-packages

if gh api "repos/$GITHUB_REPOSITORY/releases/tags/$TAG" > "$TEMP_DIR/release.json" 2> "$TEMP_DIR/error"; then
  gh release download "$TAG" --repo "$GITHUB_REPOSITORY" --pattern maintenance-plan.sha256 --dir "$TEMP_DIR"
  test "$(cat "$TEMP_DIR/maintenance-plan.sha256")" = "$MAINTENANCE_PLAN_HASH"
  # Re-index the actual published archive, preserving its digest on retries.
  gh release download "$TAG" --repo "$GITHUB_REPOSITORY" --pattern "$PACKAGE" --dir .cr-release-packages
else
  grep -q 'HTTP 404' "$TEMP_DIR/error"
  cr package charts/exivity --package-path .cr-release-packages
  cr upload -o "$OWNER" -r "$REPOSITORY" -c "$(git rev-parse HEAD)"
  printf '%s\n' "$MAINTENANCE_PLAN_HASH" > "$TEMP_DIR/maintenance-plan.sha256"
  gh release upload "$TAG" "$TEMP_DIR/maintenance-plan.sha256" --repo "$GITHUB_REPOSITORY"
fi

# Always repair/verify the index after a matching upload, including retries.
cr index -o "$OWNER" -r "$REPOSITORY" -c "https://$OWNER.github.io/$REPOSITORY" --push
