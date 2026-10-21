# PHP security maintenance candidate v3.39.3

Status: **awaiting the official upstream PHP patch**. This branch does not yet fix the reported vulnerabilities and must remain a draft.

Released source baseline: `exivity-3.39.2` (`8ea7b370181cb53461dc75a951864dbcf1db0dce`). The target is a normal Exivity release; the version must still be confirmed unused before publication.

- [ ] Verify all 13 release image selections, including Proximity API/CLI and Pigeon.
- [ ] Keep the ordinary `exivity-3.39.3` image tags; customers need no image overrides.
- [ ] Record this final chart commit in the coordinator selection and freeze/verify the release plan.
- [ ] Publish only after every selected release image is promoted and verified.

Do not merge unrelated application development into this maintenance branch. Do not move existing release tags. Link the final tested commit and candidate image digests from the coordinator release PR. Remove this preparation checklist when completing the patch.
