// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:opentelemetry_semantics/incubating.dart';
import 'package:opentelemetry_semantics/opentelemetry_semantics.dart';
import 'package:test/test.dart';

// Both libraries get the same treatment. The duplicate-key invariant is
// deliberately checked *within* a library and never across the two: the
// namespaces that hold both stable and unstable conventions are declared
// in each, so every stable key exists twice by design.
void main() {
  invariants(
    'stable',
    attributeEnums: SemconvRegistry.allAttributeEnums,
    valueEnums: SemconvRegistry.allValueEnums,
    intValueEnums: SemconvRegistry.allIntValueEnums,
    metricEnums: SemconvRegistry.allMetricEnums,
    eventEnums: SemconvRegistry.allEventEnums,
    entityEnums: SemconvRegistry.allEntityEnums,
    schemaVersion: SemconvRegistry.schemaVersion,
    registryCommit: SemconvRegistry.registryCommit,
  );
  invariants(
    'incubating',
    attributeEnums: SemconvRegistryIncubating.allAttributeEnums,
    valueEnums: SemconvRegistryIncubating.allValueEnums,
    intValueEnums: SemconvRegistryIncubating.allIntValueEnums,
    metricEnums: SemconvRegistryIncubating.allMetricEnums,
    eventEnums: SemconvRegistryIncubating.allEventEnums,
    entityEnums: SemconvRegistryIncubating.allEntityEnums,
    schemaVersion: SemconvRegistryIncubating.schemaVersion,
    registryCommit: SemconvRegistryIncubating.registryCommit,
  );
}

void invariants(
  String library, {
  required List<List<OTelSemantic>> attributeEnums,
  required List<List<OTelSemanticValue>> valueEnums,
  required List<List<OTelSemanticIntValue>> intValueEnums,
  required List<List<OTelMetric>> metricEnums,
  required List<List<OTelEvent>> eventEnums,
  required List<List<OTelEntity>> entityEnums,
  required String schemaVersion,
  required String registryCommit,
}) {
  group('Semconv invariants ($library)', () {
    final keyFormat = RegExp(r'^[a-z0-9_.]+$');

    test('no duplicate attribute keys within the library', () {
      final owners = <String, List<String>>{};
      for (final values in attributeEnums) {
        for (final member in values) {
          owners
              .putIfAbsent(member.key, () => [])
              .add(member.runtimeType.toString());
        }
      }
      final dups = Map.fromEntries(
        owners.entries.where((e) => e.value.length > 1),
      );
      expect(
        dups,
        isEmpty,
        reason: 'attribute keys must be defined exactly once per library',
      );
    });

    test('every attribute key is well-formed and toString() returns it', () {
      for (final values in attributeEnums) {
        for (final member in values) {
          expect(member.key, matches(keyFormat));
          expect(member.toString(), equals(member.key));
        }
      }
    });

    test('every value enum member round-trips through toString()', () {
      for (final values in valueEnums) {
        for (final member in values) {
          expect(member.toString(), equals(member.value));
        }
      }
      for (final values in intValueEnums) {
        for (final member in values) {
          expect(member.toString(), equals(member.value.toString()));
        }
      }
    });

    test('every metric has a well-formed name, instrument, and unit', () {
      for (final values in metricEnums) {
        for (final metric in values) {
          expect(metric.name, matches(keyFormat));
          expect(metric.toString(), equals(metric.name));
          expect(metric.unit, isNotEmpty);
        }
      }
    });

    test('every event name is well-formed', () {
      for (final values in eventEnums) {
        for (final event in values) {
          expect(event.name, matches(keyFormat));
          expect(event.toString(), equals(event.name));
        }
      }
    });

    test('entities reference only registered attribute keys', () {
      final allKeys = <String>{
        for (final values in attributeEnums)
          for (final member in values) member.key,
      };
      for (final values in entityEnums) {
        for (final entity in values) {
          expect(entity.name, matches(keyFormat));
          expect(entity.toString(), equals(entity.name));
          for (final attr in [...entity.identifying, ...entity.descriptive]) {
            expect(
              allKeys,
              contains(attr.key),
              reason:
                  'entity ${entity.name} references unregistered ${attr.key}',
            );
          }
        }
      }
    });

    test('registry records its source version', () {
      expect(schemaVersion, isNotEmpty);
      expect(registryCommit, isNot('unknown'));
      expect(attributeEnums, isNotEmpty);
    });
  });
}
