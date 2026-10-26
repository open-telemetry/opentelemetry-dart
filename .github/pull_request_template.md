<!-- Ex. Fixing a bug: describe the bug and how this fixes it. Ex. Adding a feature: explain what this achieves. -->
#### Description

<!-- Issue number (e.g. #1234) or full URL to the issue, if applicable. -->
#### Link to tracking issue
Fixes #

<!-- Which package(s) does this touch? (e.g. api, sdk, a contrib/instrumentation package) -->
#### Package(s) affected

<!-- Which tests were added, and what do they prove? If no tests were added, say why. New behaviour without a test that fails before the change is rarely ready. A green CI run only shows that nothing already covered broke, not that the new code works. -->
#### Testing

<!-- Guidance for the checklist below. Please read it before ticking a box.

     CHANGELOG. `CHANGELOG.md` is written for app developers: it covers the public API and stays brief. Skip it for internal-only work such as tests or refactors.
     Never skip it for a breaking change. Put the entry under `### Changed` or `### Removed` and prefix the bullet with `**BREAKING**: `. Breaking means any change to public API (a signature, a name, a default, a removed member, or an exported type), even when it seems minor.

     Documentation. Say what you added or updated, and where.

     Spec compliance. Link the relevant OpenTelemetry spec section(s) and quote the requirement, e.g. https://opentelemetry.io/docs/specs/otel/... Where the spec offers a SHOULD alongside a permissive MAY, we take the SHOULD unless there is a documented reason we cannot.

     Local verification. CI for first-time contributors needs maintainer approval before it runs, so the git hooks are usually your first feedback. See CONTRIBUTING.md, "Install the git hooks".

     Authorship. If AI generated the bulk of any commit, disclose it with an `Assisted-by:` commit trailer as described in CONTRIBUTING.md (e.g. `Assisted-by: Claude Opus 4.5`) and name the same tools in the checklist. Write "None" if no AI was involved. AI agents must not check the last box on behalf of the user. A human must confirm they authored and stand behind the change. -->
#### PR Readiness Checklist
- [ ] `CHANGELOG.md` updated, or not needed for this change
- [ ] Documentation is updated, or not needed for this change
- [ ] Changes are verified with spec compliance, or not applicable:
- [ ] `./tool/setup-hooks.sh` is installed, or `tool/coverage.sh` passes locally
- [ ] Assisted-by (AI tools used, or "None"):
- [ ] I, a human, authored this pull request and stand behind these changes.

<!-- Please delete any section above that doesn't apply before submitting, but keep the checklist. -->
