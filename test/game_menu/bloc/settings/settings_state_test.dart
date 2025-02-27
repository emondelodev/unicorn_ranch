// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:unicorn_ranch/game_menu/game_menu.dart';

void main() {
  group('SettingsState', () {
    test('supports value equality', () {
      expect(
        SettingsState(musicVolume: 0.5),
        equals(SettingsState(musicVolume: 0.5)),
      );
    });

    group('constructor', () {
      test('can be instantiated', () {
        expect(SettingsState(), isNotNull);
      });

      test('throws AssertionError if musicVolume is not between 0 and 1', () {
        expect(() => SettingsState(musicVolume: -0.1), throwsAssertionError);
        expect(() => SettingsState(musicVolume: 1.1), throwsAssertionError);
      });
    });

    group('copyWith', () {
      test('empty', () {
        final state = SettingsState(musicVolume: 0.5);
        expect(
          state.copyWith(),
          equals(SettingsState(musicVolume: 0.5)),
        );
      });

      test('returns a new instance with the given musicVolume', () {
        final state = SettingsState(musicVolume: 0.5);
        expect(
          state.copyWith(musicVolume: 0.6),
          equals(SettingsState(musicVolume: 0.6)),
        );
      });
    });
  });
}
