# Uses FVM when it is installed; override with `make FLUTTER=flutter DART=dart`.
FVM     := $(shell command -v fvm 2>/dev/null)
FLUTTER ?= $(if $(FVM),fvm flutter,flutter)
DART    ?= $(if $(FVM),fvm dart,dart)
APP     ?= mobile
ENV_FILE ?= $(CURDIR)/.env.json
DEFINES := $(if $(wildcard $(ENV_FILE)),--dart-define-from-file=$(ENV_FILE),)
ENV ?= dev
DEVICE ?=
DEVICE_FLAG := $(if $(DEVICE),-d $(DEVICE),)
FORMAT_DIRS := apps packages scripts test

.PHONY: setup dev test fmt analyze check index e2e build-web update-check release-ios release-android

setup:
	$(if $(FVM),fvm install,)
	$(FLUTTER) pub get
	@if command -v lefthook >/dev/null 2>&1; then lefthook install; else echo "lefthook not found, skipping git hooks"; fi

dev:
	cd apps/$(APP) && $(FLUTTER) run $(DEVICE_FLAG) $(DEFINES)

# Runs `flutter test` in every member that has a test/ folder; the root's own
# tests (test/) are the architecture checker's.
test:
	@set -e; for d in . $(filter-out .,$(patsubst %/test,%,$(wildcard apps/*/test packages/*/test))); do \
		echo "== flutter test ($$d)"; (cd $$d && $(FLUTTER) test); \
	done

fmt:
	$(DART) format $(FORMAT_DIRS)

analyze:
	$(FLUTTER) analyze

check:
	$(DART) format --output=none --set-exit-if-changed $(FORMAT_DIRS)
	$(FLUTTER) analyze
	$(DART) run scripts/check_architecture.dart
	$(DART) run scripts/check_locales.dart
	$(DART) run scripts/agent_index.dart --check
	$(MAKE) test

# Regenerates the index of shared code in AGENTS.md.
index:
	$(DART) run scripts/agent_index.dart

# Smoke test in headless Chrome via chromedriver when available, else on a device
# (`make e2e DEVICE=<id>`; list them with `flutter devices`).
e2e:
	@if command -v chromedriver >/dev/null 2>&1; then \
		cd apps/$(APP); \
		chromedriver --port=4444 & PID=$$!; sleep 2; \
		$(FLUTTER) drive --driver=integration_test/driver.dart \
			--target=integration_test/app_test.dart -d web-server --browser-name=chrome --headless; \
		RC=$$?; kill $$PID; exit $$RC; \
	else \
		echo "chromedriver not found; running on a device"; \
		cd apps/$(APP) && $(FLUTTER) test integration_test $(DEVICE_FLAG) $(DEFINES); \
	fi

build-web:
	cd apps/$(APP) && $(FLUTTER) build web $(DEFINES)

update-check:
	./scripts/update-check

# Local release: runs the gate, then builds and uploads with fastlane (see docs/release.md).
# ENV (dev or prod, default dev) is checked and shown in the Slack message; both use the same app id
# until the product adds flavors (see docs/release.md).
release-ios: check
	cd apps/$(APP)/ios && FLUTTER="$(FLUTTER)" DEFINES="$(DEFINES)" bundle exec fastlane beta env:$(ENV)

release-android: check
	cd apps/$(APP)/android && FLUTTER="$(FLUTTER)" DEFINES="$(DEFINES)" bundle exec fastlane beta env:$(ENV)
