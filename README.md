# OpenTelemetry Dart

The [OpenTelemetry](https://opentelemetry.io/) implementation for [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/).

## Project status

This repository is being bootstrapped. The packages are scaffolds with no
public API yet, and nothing here is released. See the
[package design](docs/design/packages.md) for the plan.

Eventually this will be like the other projects and have a level of release
per signal.

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

This repository is one Pub workspace. All packages in it resolve together from
the root directory. One `dart pub get` in the root directory is enough for all
of them.

1. Clone this repository.
2. Go to the root directory.
3. Run `dart pub get`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Maintainers

- TODO

For more information about the maintainer role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#maintainer).

## Approvers

- TODO

For more information about the approver role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#approver).

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
