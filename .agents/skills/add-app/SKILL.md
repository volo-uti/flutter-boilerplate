---
name: add-app
description: Add another app (for example admin next to the consumer app) to the workspace. Use when a separate deployable UI is needed that shares packages with the existing app.
---

# Add an app

1. Run `scripts/add-app <name>` from the repo root. It copies `apps/mobile` without its features (shell, theme, l10n, router, not-found page), names the package `<name>`, sets the Android id to `<mobile applicationId>.<name>` and the iOS bundle id to `<mobile bundle id>.<name in camelCase>`, registers `apps/<name>` in the root `pubspec.yaml` and runs `pub get`.
2. Run `make check`; it must pass with no other edit (the checkers pick the app up from the folder).
3. Run it with `make dev APP=<name>`; build with `make build-web APP=<name>`.
4. Build the app's features in `apps/<name>/lib/features/` with the `add-feature` skill. Code needed by several apps goes through the `share-feature` skill; never import another app.
5. The new app starts with a welcome page at `/`; replace it with a real home feature and update `apps/<name>/test/` and `integration_test/` accordingly.
6. Set real titles in `apps/<name>/lib/l10n/*.arb` and run `fvm flutter gen-l10n` in the app folder.
