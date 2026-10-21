# PHP security maintenance candidate v3.39.3

Status: **chart preparation ready for review**. This PR may merge into `maintenance/3.39` before the PHP builds are available. Merging it does not publish a chart or update customer deployments. Publication must wait for patched images and the verified coordinator plan.

Released source baseline: `exivity-3.39.2` (`8ea7b370181cb53461dc75a951864dbcf1db0dce`). The target is a normal Exivity release; the version must still be confirmed unused before publication.

- [x] Prepare the chart version, maintenance marker and publication guards on the released baseline.
- [x] Keep chart values/templates unchanged and use ordinary `exivity-3.39.3` image tags.
- [x] Pass local Helm lint/render checks and workflow lint.
- [ ] Merge this preparation and record the final merged chart commit in the coordinator selection.
- [ ] Verify all 13 release image selections, including Proximity API/CLI and Pigeon, once the patched builds exist.
- [ ] Freeze and verify the final release plan.
- [ ] Publish only after every selected release image is promoted and verified.

Chart publication runs through the coordinator's explicit maintenance workflow and requires the planned release tag. The merge itself has no chart-release trigger on `maintenance/3.39`.

Do not merge unrelated application development into this maintenance branch. Do not move existing release tags. Link the final tested commit and candidate image digests from the coordinator release PR. Remove this preparation checklist when completing the patch.
