# Contributing

## Run the checks

CI runs these commands. Run them before you open a pull request.

```bash
dart format .
dart analyze --fatal-infos
tool/check_license_header.sh
dart test
```

Run the first three commands in the root directory. They cover every package.
Run `dart test` in the directory of the package that you changed.

CI runs the tests of each package against Dart 3.8.0 and against the current
stable Dart SDK. Dart 3.8.0 is the minimum version that the packages declare.
Do not lower it: `package:lints` 6 needs Dart 3.8.0.

## License header

Every Dart and shell source file starts with this header. CI checks it.

```dart
// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0
```

In a shell script, use `#` instead of `//`, after the shebang line.

## Add a package

1. Make a directory for the package in `packages/`.
2. Add `resolution: workspace` to the `pubspec.yaml` file of the package.
3. Add the directory to the `workspace` list in the root `pubspec.yaml` file.
4. Run `dart pub get` in the root directory.
