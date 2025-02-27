// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:unicorn_ranch/game/entities/entities.dart';
import 'package:unicorn_ranch/game/game.dart';

void main() {
  group('BlessingEvent', () {
    group('UnicornSpawned', () {
      test('can be instantiated', () {
        expect(UnicornSpawned(), isNotNull);
      });
      test('supports value equality', () {
        expect(
          UnicornSpawned(),
          equals(UnicornSpawned()),
        );
      });
    });
    group('UnicornDespawned', () {
      test('can be instantiated', () {
        expect(const UnicornDespawned(UnicornEvolutionStage.teen), isNotNull);
      });
      test('supports value equality', () {
        expect(
          UnicornDespawned(UnicornEvolutionStage.child),
          equals(UnicornDespawned(UnicornEvolutionStage.child)),
        );
      });
    });
    group('UnicornEvolved', () {
      test('can be instantiated', () {
        expect(
          const UnicornEvolved(to: UnicornEvolutionStage.adult),
          isNotNull,
        );
      });
      test('supports value equality', () {
        expect(
          UnicornEvolved(to: UnicornEvolutionStage.teen),
          equals(UnicornEvolved(to: UnicornEvolutionStage.teen)),
        );
      });
    });
  });
}
