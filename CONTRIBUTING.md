# Contributing

Thanks for taking the time to improve this template. It is meant to be cloned and renamed with `scripts/init`, so changes here should keep a fresh clone working with no extra steps.

By taking part you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Set up

You need [FVM](https://fvm.app). The Flutter version is pinned in `.fvmrc`; everything else comes from the pubspecs.

```
git clone https://github.com/volo-uti/flutter-boilerplate
cd flutter-boilerplate
make setup   # installs the pinned SDK and dependencies, enables git hooks if lefthook is installed
make dev     # runs apps/mobile with mock data
```

[lefthook](https://github.com/evilmartians/lefthook) is optional. When it is installed, `make setup` enables a pre-commit format and analyze check and a pre-push `make check`.

## The gate

```
make check
```

This is the one command that decides whether a change is done. It checks formatting, runs the analyzer, verifies the architecture and dependency rules, locale parity and the freshness of the generated index in `AGENTS.md`, and runs the tests of every workspace member. The pre-push hook runs the same command, and there is no remote CI. A pull request is ready for review when `make check` passes.

## Project structure

```
apps/<app>/          an app (default: mobile); features live in lib/features/<name>/
packages/app_ui/     theme and atomic widgets
packages/app_shared/ Result, Failure and the HTTP port with its adapters
scripts/             init, add-app, update-check and the check scripts used by make check
```

[AGENTS.md](AGENTS.md) describes the rules agents and humans follow: the layer rules, where code goes and how the shared-code index is generated. [PRINCIPLES.md](PRINCIPLES.md) explains why the template is built this way.

## Conventions that matter

- Layers point inwards (`presentation -> application -> domain <- data`) and features never import each other. `scripts/check_architecture.dart` enforces this, so a violation fails `make check`.
- Expected failures return `Result<T>`; do not throw for them.
- Every ARB file of an app has the same keys, and UI strings are never hard-coded.
- Look in the index in `AGENTS.md` before writing a widget or helper. After adding or changing public declarations in `app_ui`, `app_shared` or a feature's `application/`, run `make index`.
- Versions live in the pubspecs and `.fvmrc` only. Do not repeat them in documentation.
- Keep the template minimal: do not add something every new project would have to delete.
- Documentation, code, comments and commit messages are written in English.

## Pull requests

1. Fork the repository and create a branch from `main`.
2. Make one focused change. Add or update tests with it.
3. Run `make check` until it passes.
4. Write commit messages as [Conventional Commits](https://www.conventionalcommits.org) (`feat(counter): add reset`, `fix: handle empty response`).
5. Open a pull request and fill in the template. Describe what changed and why.

Changes to `scripts/init` need a smoke test: run it in a throwaway copy of the repository, never in your working clone, because it deletes the git history.

## Reporting bugs and security issues

Open an issue with the bug report form for ordinary bugs and the feature request form for ideas. Do not report vulnerabilities in public issues; follow [SECURITY.md](SECURITY.md) instead.
