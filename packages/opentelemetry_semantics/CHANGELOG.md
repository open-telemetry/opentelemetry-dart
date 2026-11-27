## 0.1.0-dev

- Initial version: the semantic-convention enums, candidate attribute keys
  and OTel Weaver generator donated from
  `MindfulSoftwareLLC/dartastic_opentelemetry_api`.
- Split the generated conventions into two libraries:
  `opentelemetry_semantics.dart` carries the conventions the registry marks
  `stable`, and `incubating.dart` carries every convention with its types
  suffixed `Incubating`.
