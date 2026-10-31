# OpenTelemetry Dart

OpenTelemetry for Dart. This repository is one Pub workspace. All packages in
it resolve together from the root directory. One `dart pub get` in the root
directory is enough for all of them.

The packages have no content yet. The content of each package comes in a
separate pull request.

## Packages

| Directory | Content |
| --- | --- |
| `packages/opentelemetry_api` | The API. Pure Dart, and a no-op by default. |
| `packages/opentelemetry_sdk` | The SDK, the exporter interfaces, and the built-in exporters. |
| `packages/opentelemetry_semantics` | The semantic conventions. |
| `packages/opentelemetry` | The entry point for a Dart application. |

## Requirements

The Dart SDK, version 3.8.0 or later.

## Get started

1. Clone this repository.
2. Go to the root directory.
3. Run `dart pub get`.

## Run the checks

CI runs these three commands. Run them before you open a pull request.

```bash
dart format .
dart analyze --fatal-infos
dart test
```

Run the first two commands in the root directory. They cover every package.
Run `dart test` in the directory of the package that you changed.

CI runs the tests of each package against Dart 3.8.0 and against the current
stable Dart SDK. Dart 3.8.0 is the minimum version that the packages declare.

## Add a package

1. Make a directory for the package in `packages/`.
2. Add `resolution: workspace` to the `pubspec.yaml` file of the package.
3. Add the directory to the `workspace` list in the root `pubspec.yaml` file.
4. Add the name of the package to the `package` matrix in `.github/workflows/ci.yml`.
5. Run `dart pub get` in the root directory.

## Maintainers

- TODO

For more information about the maintainer role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#maintainer).

## Approvers

- TODO

For more information about the approver role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#approver).
