// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// OpenTelemetry semantic conventions for Dart — the **stable** surface.
///
/// Every convention here is marked `stable` in the OpenTelemetry
/// semantic-conventions registry, so its name and wire value carry the
/// registry's compatibility promise.
///
/// The conventions the registry still calls `development`,
/// `release_candidate` or `alpha` live in
/// `package:opentelemetry_semantics/incubating.dart`, which is a superset:
/// it re-declares everything here under an `Incubating`-suffixed name, so
/// importing both at once does not collide and code does not break when a
/// convention graduates. Instrumentation libraries should prefer this
/// library; the incubating one is for applications.
library;

export 'src/http_header_attribute.dart';
export 'src/semantics_base.dart';
export 'src/stable/semconv.dart';
