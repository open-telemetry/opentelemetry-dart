// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// OpenTelemetry semantic conventions for Dart — **every** convention,
/// stable and unstable alike.
///
/// A superset of `package:opentelemetry_semantics/opentelemetry_semantics.dart`:
/// every type is suffixed `Incubating`, including the ones that are
/// already stable, so that both libraries can be imported together and so
/// that code keeps compiling when a convention graduates. Prefer the
/// stable library for anything whose name you do not want to re-type
/// later.
///
/// Nothing here is covered by a compatibility promise: a convention the
/// registry calls `development`, `release_candidate` or `alpha` may be
/// renamed, retyped or removed in a minor release. This library also
/// carries the hand-maintained `candidates/` keys, which the registry does
/// not define at all — see `doc/SEMCONV_CANDIDATES.md`.
library;

export 'src/candidates/candidates.dart';
export 'src/http_header_attribute.dart';
export 'src/incubating/semconv.dart';
export 'src/semantics_base.dart';
