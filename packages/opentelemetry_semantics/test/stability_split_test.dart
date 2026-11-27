// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Guards the one thing the two-library split can get wrong and nothing
// else checks: which library a convention lands in. The generated audits
// assert that every convention matches the registry; they do not assert
// that the stable library holds exactly the stable ones.
library;

import 'package:opentelemetry_semantics/incubating.dart';
import 'package:opentelemetry_semantics/opentelemetry_semantics.dart';
import 'package:test/test.dart';

import 'semconv/semconv_expected.g.dart';

Set<String> _keys(List<List<OTelSemantic>> enums) => {
  for (final values in enums)
    for (final member in values) member.key,
};

void main() {
  final stableKeys = _keys(SemconvRegistry.allAttributeEnums);
  final incubatingKeys = _keys(SemconvRegistryIncubating.allAttributeEnums);

  group('stable library', () {
    test('contains only conventions the registry calls stable', () {
      final wrong = <String, String>{};
      for (final key in stableKeys) {
        final stability = semconvExpectedStabilityByKey[key];
        if (stability != 'stable') {
          wrong[key] = stability ?? '<not in registry>';
        }
      }
      expect(wrong, isEmpty, reason: 'these are not stable in the registry');
    });

    test('contains every stable convention in the registry', () {
      final missing = semconvExpectedStabilityByKey.entries
          .where((e) => e.value == 'stable' && !stableKeys.contains(e.key))
          .map((e) => e.key)
          .toList();
      expect(missing, isEmpty, reason: 'stable keys absent from the library');
    });

    test('entities reference only attributes this library declares', () {
      for (final values in SemconvRegistry.allEntityEnums) {
        for (final entity in values) {
          for (final attr in [...entity.identifying, ...entity.descriptive]) {
            expect(
              stableKeys,
              contains(attr.key),
              reason: '${entity.name} reaches outside the stable surface',
            );
          }
        }
      }
    });
  });

  group('incubating library', () {
    test('is a superset of the stable one', () {
      expect(
        stableKeys.difference(incubatingKeys),
        isEmpty,
        reason: 'a graduated convention must keep its incubating twin',
      );
    });

    test('carries conventions the stable library omits', () {
      expect(incubatingKeys.length, greaterThan(stableKeys.length));
    });

    for (final (kind, stable, incubating) in [
      (
        'metrics',
        SemconvRegistry.allMetricEnums.expand((e) => e).map((m) => m.name),
        SemconvRegistryIncubating.allMetricEnums
            .expand((e) => e)
            .map((m) => m.name),
      ),
      (
        'events',
        SemconvRegistry.allEventEnums.expand((e) => e).map((m) => m.name),
        SemconvRegistryIncubating.allEventEnums
            .expand((e) => e)
            .map((m) => m.name),
      ),
      (
        'entities',
        SemconvRegistry.allEntityEnums.expand((e) => e).map((m) => m.name),
        SemconvRegistryIncubating.allEntityEnums
            .expand((e) => e)
            .map((m) => m.name),
      ),
    ]) {
      test('is a superset of the stable $kind', () {
        expect(stable.toSet().difference(incubating.toSet()), isEmpty);
      });
    }
  });

  group('both libraries agree on provenance', () {
    test('same registry version', () {
      expect(
        SemconvRegistry.schemaVersion,
        equals(SemconvRegistryIncubating.schemaVersion),
      );
      expect(
        SemconvRegistry.registryCommit,
        equals(SemconvRegistryIncubating.registryCommit),
      );
    });
  });
}
