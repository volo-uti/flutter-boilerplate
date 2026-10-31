# Releasing

Test, build and deploy all happen on your own machine. There is no remote CI: `make check` is the gate and the pre-push hook runs it. Deployment uses [fastlane](https://fastlane.tools), and a Slack bot reports when a release starts, finishes or fails.

## Requirements

- macOS for iOS (Xcode is required). Windows developers work inside WSL2 and can ship Android only.
- Ruby with Bundler, then `bundle install` once at the repository root. Commit the generated `Gemfile.lock` so everyone uses the same fastlane version.
- The usual toolchain from `make setup`.

## Commands

| Command | What it does |
|---|---|
| `make release-ios` | `make check`, then build and upload to TestFlight |
| `make release-android` | `make check`, then build and upload to the Play internal track |

Pass `ENV=dev` (default) or `ENV=prod`. To build without uploading, run the `build` lane by hand: `cd apps/mobile/ios && bundle exec fastlane build env:dev` (same for `android`). Both lanes read `.env.json` through the same `--dart-define-from-file` rule as `make dev`.

The build number is the latest one in the store plus one (`latest_testflight_build_number`, `google_play_track_version_codes`), so two machines can release without coordinating. `dev` and `prod` currently share the app id in the Appfiles; give `dev` its own id (for example with flavors) if you want separate store records.

## Environment variables

Set them in your shell or a gitignored file you source. Never commit values.

| Name | Used for |
|---|---|
| `ASC_KEY_ID` | App Store Connect API key id (a Team key) |
| `ASC_ISSUER_ID` | App Store Connect issuer id |
| `ASC_KEY_CONTENT` | Contents of the `.p8` key file |
| `APPLE_TEAM_ID` | Apple developer team id |
| `PLAY_JSON_KEY_PATH` | Path to the Google Play service account JSON; unset falls back to Application Default Credentials |
| `SLACK_BOT_TOKEN` | Slack bot token with the `chat:write` scope (optional) |
| `SLACK_CICD_CHANNEL` | Channel id the bot posts to (optional) |

iOS signing is cloud-managed through the API key, so there is no `match` repository.

Android release signing reads `apps/mobile/android/key.properties` (gitignored) with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`. Without that file the release build uses the debug key, which Play rejects.

## Slack

Create a Slack app with the `chat:write` scope, install it, invite the bot to the channel and set the two variables. A lane then posts a start message, then a success or failure message. If either variable is missing nothing is sent, and a failed notification only prints a warning.

## Before the first real release

The lanes have not been run against a real store from the template. Do one manual pass first: run `build` for each platform, check the artifact, then run `beta` and confirm the build appears in TestFlight or the Play internal track.
