---
name: share-feature
description: Move a feature from one app into a shared package so several apps can use it. Use when a second app needs a feature that lives in apps/<app>/lib/features/<f>.
---

# Share a feature

Result: `packages/<f>/` with the same four layers, used by every app that needs it. Rules for packages are in `AGENTS.md` and checked by `make check`.

1. Create `packages/<f>/` with `pubspec.yaml`: `name: <f>`, `publish_to: none`, `version: 0.1.0`, `resolution: workspace`, the same `environment.sdk` as the other members, and only the dependencies the code uses (same constraints as elsewhere). Depend on `app_shared: any` / `app_ui: any` as needed.
2. Move `apps/<app>/lib/features/<f>/{domain,application,data,presentation}` to `packages/<f>/lib/{domain,application,data,presentation}` and move the matching tests to `packages/<f>/test/`.
3. Rewrite imports to `package:<f>/...`. The package must not import any app, so strings go in as parameters (labels, callbacks), not `AppLocalizations`.
4. Register `packages/<f>` in the root `pubspec.yaml` under `workspace:`.
5. In every app that uses it, add `<f>: any` to its `pubspec.yaml` dependencies and wire providers and routes in its `lib/app/`. Run `fvm flutter pub get` at the root.
6. Run `make check`. Layer rules apply inside the package exactly as inside an app feature.
