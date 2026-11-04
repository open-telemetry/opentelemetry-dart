# opentelemetry_semantics

OpenTelemetry semantic conventions for Dart: attribute keys and values,
metric names, event names and entity definitions, as Dart enums.

## Two entry points

The registry marks each convention `stable`, `release_candidate`,
`development` or `alpha`, and only `stable` carries a compatibility
promise. This package splits on that line, the way
`@opentelemetry/semantic-conventions` splits `.` from `/incubating`:

```dart
// stable only - names and wire values will not change under you
import 'package:opentelemetry_semantics/opentelemetry_semantics.dart';

// every convention, stable and unstable alike
import 'package:opentelemetry_semantics/incubating.dart';
```

```dart
void main() {
  print(Http.httpRequestMethod.key); // http.request.method
  print(HttpMetric.httpServerRequestDuration.name);
  print(HttpHeaderAttribute.request('content-type').key);
}
```

The incubating library is a **superset**: every type it shares with the
stable one is re-declared there under an `Incubating`-suffixed name
(`HttpIncubating`, `HttpMetricIncubating`, `SemconvRegistryIncubating`).
Two consequences, both deliberate:

- You can import both libraries at once without a name collision.
- Code keeps compiling when a convention graduates, because its
  incubating name does not disappear.

The suffix is on the incubating side because 20 of the 79 attribute
namespaces hold stable *and* unstable conventions - `http`, `k8s`, `db`,
`url`, `network` among them - and a Dart enum cannot be split across two
libraries. Those namespaces are therefore declared in both.

Instrumentation libraries should depend on the stable library; the
incubating one is meant for applications. That is the
[OpenTelemetry recommendation](https://opentelemetry.io/docs/specs/semconv/non-normative/code-generation/).

Every attribute-key enum implements `OTelSemantic`, so your own
app-specific enums can implement it too and mix into the same maps.

## Layout

| Path | Contents |
| --- | --- |
| `lib/src/semantics_base.dart` | the `OTelSemantic`, `OTelMetric`, `OTelEvent` and `OTelEntity` base interfaces |
| `lib/src/stable/` | generated; the conventions the registry calls `stable` — do not edit |
| `lib/src/incubating/` | generated; every convention, `Incubating`-suffixed — do not edit |
| `lib/src/candidates/` | hand-maintained keys the registry does not define yet; incubating-only, see [doc/SEMCONV_CANDIDATES.md](doc/SEMCONV_CANDIDATES.md) |

## Regenerating `semconv/`

`lib/src/stable/`, `lib/src/incubating/` and the audit fixtures in
`test/semconv/` are produced by
[OTel Weaver](https://github.com/open-telemetry/weaver) from the
[semantic-conventions](https://github.com/open-telemetry/semantic-conventions)
registry. Docker is the only prerequisite. The script pins the registry
version and fetches it, so no checkout is needed. It removes what it
fetched on every exit, including a failure, so the working tree is left as
it was found:

```bash
tool/semconv/generate.sh          # regenerate in place
tool/semconv/generate.sh --check  # verify the committed output is fresh
```

The pinned version is `SEMCONV_VERSION` at the top of
`tool/semconv/generate.sh`. Bump it deliberately: it rewrites every
generated file. The script refuses a registry whose schema version does not
match the pin, so the committed output always corresponds to one registry
release.

To try a registry that has no release yet, point `SEMCONV_REPO` at a local
checkout. Its schema version must still match the pin.
