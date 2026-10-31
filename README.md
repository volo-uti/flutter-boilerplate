# Flutter Boilerplate

A Flutter template for iOS, Android and web, organised as a Dart pub workspace (`apps/` + `packages/`) so you can add more apps (admin, ...) next to the first one. Built to be cloned and renamed. It runs right after clone with no code generation and mock data by default.

- State and DI: Riverpod (hand-written providers)
- Routing: go_router
- Errors: sealed `Result<T>` / `Failure`
- HTTP: dio behind a port, with a mock adapter
- i18n: gen-l10n (en, ko), generated files committed
- Theme: Material 3, light and dark, with a `ThemeExtension` for app tokens
- Shared packages: `app_ui` (theme and atomic widgets), `app_shared` (Result, Failure, HTTP port)
- Quality gate: `make check` (format, analyze, architecture rules, locale parity, tests)

## Quick start

```
git clone https://github.com/volo-uti/flutter-boilerplate my_app
cd my_app
scripts/init --name my_app --org com.mycompany
make setup
make dev
```

`scripts/init` sets the workspace name and the mobile app's bundle ids and titles, rewrites this README, removes the template's license and community files (contributing guide, code of conduct, security policy, principles, issue and pull request templates) and starts a fresh git repository. Pass `--nested` if the app lives in a subfolder (for example `<product>/app/`) of a larger repo.

Requires [FVM](https://fvm.app) (the Flutter version is pinned in `.fvmrc`). [lefthook](https://github.com/evilmartians/lefthook) is optional; if installed, `make setup` enables git hooks.

## Commands

| Command | Purpose |
|---|---|
| `make setup` | install the pinned SDK, dependencies and git hooks |
| `make dev` | run an app (`APP=mobile` by default) |
| `make check` | the gate: format, analyze, architecture, locales, tests |
| `make e2e` | integration smoke test |
| `make build-web` | production web build of `APP` |
| `scripts/add-app <name>` | add another app to the workspace |
| `make update-check` | report newer Flutter and dependency versions |

Configuration comes from `--dart-define` values (`API_BASE_URL`, `USE_MOCKS`); put them in `.env.json` and `make dev` passes the file along. Without it the app uses mock adapters.

## Layout

See [AGENTS.md](AGENTS.md) for the folder structure and the layer rules, which `scripts/check_architecture.dart` enforces across all apps and packages.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and the pull request process, and follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Please report vulnerabilities privately, as described in [SECURITY.md](SECURITY.md).

## Principles

[PRINCIPLES.md](PRINCIPLES.md) explains why the template is built this way and which tool enforces each rule.

## License

[MIT](LICENSE)
