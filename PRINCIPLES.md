# Principles

The rules this template follows and the reasons for them. Each principle names the tool that enforces it, so you can tell a rule that is checked from a habit. Read this before proposing a change; it explains most of the "why not X?" questions.

## Always the latest stable

Every tool and dependency is the latest stable release; no beta or release candidates. Version numbers live in one place, the pubspecs and `.fvmrc`, and documentation never repeats them, so they cannot drift apart. A dependency with no stable release for twelve months is a reason to revisit the choice, not to pin it.

Enforced by: `.fvmrc` pins the SDK; `make update-check` reports newer versions.

## Clean architecture, features first

Code is grouped by feature, and each feature has four layers: `domain`, `application`, `data` and `presentation`. Dependencies point inwards (`presentation -> application -> domain <- data`), the domain is pure Dart, and a feature never reaches into another feature. This keeps business rules testable without Flutter and lets a feature be moved or deleted as a unit.

Enforced by: `scripts/check_architecture.dart` (run by `make check`) rejects layer, feature, app and package boundary violations.

## Ports and adapters, mocks by default

Every outside dependency sits behind a port in the domain. A real adapter (`http_*`) and an in-memory adapter (`mock_*`) implement it, and the composition root picks one. The app therefore runs right after clone with no backend, and tests use the same mocks.

Enforced by: `scripts/check_architecture.dart` stops presentation and application code from importing adapters; `AppEnv.useMocks` defaults to true.

## Expected failures are values

An operation that can fail in an expected way, such as a network error, returns a sealed `Result<T>` carrying a `Failure` instead of throwing. Callers must handle both cases, and the compiler checks that they do.

Enforced by: Dart's exhaustive `switch` on sealed types, with `strict-casts`, `strict-inference` and `strict-raw-types` in `analysis_options.yaml`.

## A project stands on its own

The template works straight after `git clone`: no environment variables, no code generation step and no neighbouring repository are needed. Per-product decisions such as branding, tokens and deployment are made inside the project. `scripts/init` turns the clone into your project: it renames the workspace and bundle ids, drops the template's own community files and starts a fresh git history. With `--nested` it becomes one part of a larger repository.

Enforced by: generated localization files are committed; `make check` passes on a fresh checkout.

## Rules are enforced by tools

If a rule can be measured, a script or a lint measures it. Layer direction, feature isolation, dependency constraints, locale parity and the freshness of generated docs fail the build rather than rely on review. A rule that cannot be measured must say what breaks when it is ignored; if nothing breaks, it is not written down.

Enforced by: `make check` (`scripts/check_architecture.dart`, `scripts/check_locales.dart`, `scripts/agent_index.dart --check`, `flutter analyze`).

## One gate

`make check` formats, analyzes, checks architecture and locales, verifies the generated index and runs every test. People and agents run the same command, and "done" means it passed. There is no second, stricter pipeline that surprises you after the push.

Enforced by: the lefthook pre-push hook runs it. There is no remote CI; test, build and deploy run locally.

## Findable by agents and humans

Shared code is listed in a generated index in `AGENTS.md`, one line per declaration, taken from the first sentence of its doc comment. Reusing what exists is cheaper than rediscovering it, and an index built from the code cannot go stale. Raw widgets that have an `app_ui` replacement are rejected, and the failure message names the replacement.

Enforced by: `scripts/agent_index.dart --check` fails on a stale index or a missing doc sentence; `scripts/check_architecture.dart` rejects replaced raw widgets.

## Agent-neutral guidance

`AGENTS.md` and `.agents/skills/` are the single source of guidance for coding agents. Tool-specific files exist only where a tool cannot read the source: a `.claude/skills` link and a one-line `CLAUDE.md` that imports `AGENTS.md`. Guidance is written once, so it cannot diverge.

## Write only what is needed

Guidance covers what an agent cannot see in the code and what breaks if it is ignored; it does not restate framework knowledge a capable model already has. The same applies to the skeleton: it ships nothing a new project would have to delete. Authentication, storage, models, monitoring and similar capabilities are added when first needed, following the `add-feature` skill.

## Accessibility by default

The skeleton's widget tests run Flutter's accessibility guidelines (tap target size, labeled tap targets, text contrast), and icon buttons always carry a tooltip that doubles as their semantic label. Starting accessible is far cheaper than retrofitting.

Enforced by: `meetsGuideline` checks in `apps/mobile/test/app/app_test.dart`, run by `make check`.

## Final state only

Documentation and code describe the current state. There are no changelogs, migration notes or "previously" sections; version control keeps the history.

## Choices

What the template uses and why. Versions are in the pubspecs and `.fvmrc`.

| Concern | Choice | Why |
|---|---|---|
| SDK pinning | FVM, `.fvmrc` | One pinned Flutter version that local setup reads |
| Repository shape | Dart pub workspace: `apps/mobile`, `packages/app_ui`, `packages/app_shared` | Built into the ecosystem, so there is no second tool; more apps can be added later; fixed internal names mean no import rewriting per project |
| Language | Dart with `strict-casts`, `strict-inference`, `strict-raw-types` | Catches implicit dynamic typing at analysis time |
| Routing | `go_router`, hand-written routes | Maintained by the Flutter team and recommended by the official architecture guide |
| i18n | `gen-l10n` with ARB files | First-party tooling in the SDK; key parity is checked |
| State and DI | Riverpod, hand-written providers | One tool for state and wiring; no code generation, so a clone runs without a build step |
| Errors | Own sealed `Result` and `Failure` | The approach of the official guide; a few lines, no dependency |
| HTTP | `dio` behind an `HttpClient` port | Interceptors, timeouts and cancellation; the port keeps it swappable |
| Theme | Material 3 `ThemeData` with `ColorScheme.fromSeed` and a `ThemeExtension` for app tokens | First-party packages only |
| Widgets | Own atomic widgets in `app_ui` | Reusable across apps, with no localization inside so labels are parameters |
| Layer checks | `scripts/check_architecture.dart` | Expresses layer, feature and app boundaries; analyzer plugins that could do it are not stable |
| Lint and format | `flutter_lints`, strict analysis, `dart format` | First-party rule set |
| Tests | `flutter_test`, `mocktail`, hand-written fakes | No code generation |
| E2E | `integration_test` smoke test, outside `make check` | First-party; kept out of the fast gate |
| Git hooks | lefthook, optional | One binary, language-agnostic, works from a subfolder in a larger repository |
| Configuration | `--dart-define-from-file` with `String.fromEnvironment` defaults | The app starts with no configuration |
| Release | fastlane on the developer machine, Slack bot notifications | iOS needs Xcode anyway; one local path for test, build and deploy |
| Monthly review | `make update-check` | Reports newer Flutter and dependency versions |
