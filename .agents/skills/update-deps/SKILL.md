---
name: update-deps
description: Monthly routine to update the Flutter SDK and dependencies across the workspace. Use on the monthly maintenance pass or when asked to update versions.
---

# Update dependencies

1. Run `make update-check`. It lists the newest stable Flutter vs `.fvmrc`, outdated direct dependencies (including major bumps), and marks `REVISIT` for any dependency whose latest release is over 12 months old.
2. Bump Flutter: edit `.fvmrc`, then `fvm install`. If release notes call for platform template changes, compare against a fresh `fvm flutter create` in a temp folder and apply the diff to each app's `android/`, `ios/`, `web/`.
3. Bump dependencies: edit the constraint in every member pubspec that declares the package (the check requires identical constraints), then `fvm flutter pub get` at the root. For many at once: `fvm flutter pub upgrade --major-versions`, then confirm the constraints still match across members.
4. Run `fvm flutter gen-l10n` in each app if localization output changed, and regenerate any added codegen outputs.
5. Run `make check`. Fix breakages caused by the bump; if one cannot be fixed quickly, revert that package and record it as blocked.
6. Report three lists: updated (old -> new), blocked (and why), REVISIT (candidates for replacement).
