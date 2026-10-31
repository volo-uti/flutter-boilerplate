---
name: add-route
description: Add a page and route to an app. Use when a new screen or URL path is needed in an existing or new feature.
---

# Add a route

Paths are relative to the app, `apps/<app>/` (default `apps/mobile`).

1. Put the page in `lib/features/<feature>/presentation/<name>_page.dart` (create the feature with the `add-feature` skill if it does not exist).
2. Add strings to every ARB file in `lib/l10n/`, then run `fvm flutter gen-l10n` in the app folder.
3. Register the route in `lib/app/router.dart` inside `routerProvider`: `GoRoute(path: '/name', builder: ...)`. Wrap the page with `_Framed` to get the shared shell.
4. Navigate with `context.go('/name')` or `context.push('/name')`.
5. Add a widget test under `test/features/<feature>/presentation/` that pumps the page (or `App` and navigates).
6. Run `make check` from the repo root.

Unknown paths already render the not-found page via `errorBuilder`; do not add a catch-all route.
