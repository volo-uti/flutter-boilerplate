---
name: add-feature
description: Add a feature with its four layers, adapters, provider wiring and tests, or add an on-demand capability (models, storage, API client, monitoring, analytics, E2E) for the first time. Use for any new business capability.
---

# Add a feature

Layers are checked by `scripts/check_architecture.dart` (run by `make check`). Paths below are relative to the app, `apps/<app>/` (default `apps/mobile`).

1. Look up the index in `AGENTS.md` for widgets, shared code and use cases you can reuse. If nothing fits, say what you looked for before building it.
2. `lib/features/<name>/domain/`: entities and the repository interface (pure Dart; return `Result<T>` from `package:app_shared/domain/result.dart` for expected failures).
3. `lib/features/<name>/data/`: adapters implementing the interface, named `http_<thing>.dart` (uses `HttpClient` from `package:app_shared/data/http_client.dart`) and `mock_<thing>.dart` (in-memory, deterministic).
4. `lib/features/<name>/application/`: use cases or Riverpod `Notifier`s that depend only on domain interfaces.
5. `lib/features/<name>/presentation/`: pages and widgets built from `package:app_ui` widgets; read state with `ref.watch`.
6. Wire in `lib/app/providers.dart`: a provider for the repository that returns the `mock_` adapter when `AppEnv.useMocks` is true, else the `http_` one.
7. Add strings to every ARB file in `lib/l10n/` and run `fvm flutter gen-l10n` in the app folder.
8. Tests mirror `lib/` under `test/features/<name>/`: unit tests with hand-written fakes (or `mocktail`), plus a widget test.
9. Add the route with the `add-route` skill, then run `make index` and `make check`.

If a second app needs the feature, use the `share-feature` skill instead of copying it.

# Add a capability on demand

Add only when the first feature needs it, to the member that uses it (declare the dependency only there). Commit any generated files.

| Need | Do |
|---|---|
| Models with `copyWith` / JSON | add `freezed`, `json_serializable` (dev: `build_runner`); run `fvm dart run build_runner build` in the member; commit generated files |
| Secrets / tokens | `flutter_secure_storage`, behind a port in `domain/` |
| Local storage | `shared_preferences` (async API) for simple values, `drift` for relational data; behind a port |
| Typed API client from OpenAPI | `swagger_parser`; generated code lives in the feature's `data/` (or `app_shared/lib/data` if shared); commit it |
| Error monitoring | `sentry_flutter`; initialize in `lib/main.dart`, DSN through `AppEnv` |
| Analytics / push | Firebase (`firebase_core`, `firebase_analytics`, `firebase_messaging`) via `flutterfire configure`; wrap behind a port |
| Native E2E | `patrol`; keep it outside `make check` |
| Type-safe routes | `go_router_builder`, once it supports the current build tooling; commit generated files |

After adding codegen, note in the PR that fresh clones need no generation step because outputs are committed.
