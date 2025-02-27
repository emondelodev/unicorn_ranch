// ignore_for_file: cascade_invocations

import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicorn_ranch/game/entities/food/behaviors/behaviors.dart';
import 'package:unicorn_ranch/game/entities/food/food.dart';

import '../../../../helpers/helpers.dart';

void main() {
  final flameTester = FlameTester(TestGame.new);

  group('DespawningBehavior', () {
    flameTester.testGameWidget(
      'removes parent after given despawn time',
      setUp: (game, tester) async {
        await game.ensureAdd(
          Food.test(
            behaviors: [
              DraggingBehavior(),
              DespawningBehavior(despawnTime: 1),
            ],
          ),
        );
        await game.ready();
      },
      verify: (game, tester) async {
        final food = game.descendants().whereType<Food>().first;
        game.update(0.5);

        expect(food.isRemoving, isFalse);

        game.update(0.5);

        expect(food.isRemoving, isTrue);
      },
    );

    flameTester.testGameWidget(
      'should not remove when we are dragging the parent',
      setUp: (game, tester) async {
        await game.ensureAdd(
          Food.test(
            behaviors: [
              DraggingBehavior(),
              DespawningBehavior(despawnTime: 1),
            ],
          ),
        );
        await game.ready();
      },
      verify: (game, tester) async {
        final food = game.descendants().whereType<Food>().first;
        game.update(0.5);
        expect(food.isRemoving, isFalse);

        final gesture = await tester.createGesture();
        await gesture.down(Offset.zero);
        await gesture.moveTo(const Offset(100, 100));
        await tester.pump();
        game.update(0.5);
        expect(food.isRemoving, isFalse);

        await gesture.up();
        await tester.pump();
        await tester.pump();
        game.update(1);
        expect(food.isRemoving, isTrue);

        game.pauseEngine();
        await tester.pumpAndSettle();
      },
    );
  });
}
