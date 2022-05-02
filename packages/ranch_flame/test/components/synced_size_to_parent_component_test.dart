// ignore_for_file: cascade_invocations

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ranch_flame/ranch_flame.dart';

import '../helpers/helpers.dart';

class ParentComponent extends PositionComponent {
  ParentComponent(Vector2 size) : super(size: size);
}

class TestComponent extends SyncedSizeToParentComponent<ParentComponent> {}

void main() {
  final flameTester = FlameTester<TestGame>(TestGame.new);

  group('SyncSizeWithParent', () {
    flameTester.test('keeps size in sync with parent', (game) async {
      final originalSize = Vector2.all(64);
      final parent = ParentComponent(originalSize);
      final component = TestComponent();

      await game.ready();
      await game.ensureAdd(parent);
      await parent.ensureAdd(component);

      expect(
        component.size,
        closeToVector(originalSize.x, originalSize.y),
      );

      parent.size.multiply(Vector2.all(2));

      expect(
        component.size,
        closeToVector(originalSize.x * 2, originalSize.y * 2),
      );
    });

    flameTester.test('does not keep size in sync after removing from parent',
        (game) async {
      final originalSize = Vector2.all(64);
      final parent = ParentComponent(originalSize);
      final component = TestComponent();

      await game.ready();
      await game.ensureAdd(parent);
      await parent.ensureAdd(component);

      expect(
        component.size,
        closeToVector(originalSize.x, originalSize.y),
      );

      component.removeFromParent();
      game.update(0); // Simulate game tick

      parent.size.multiply(Vector2.all(2));

      expect(
        component.size,
        closeToVector(originalSize.x, originalSize.y),
      );
    });
  });
}
