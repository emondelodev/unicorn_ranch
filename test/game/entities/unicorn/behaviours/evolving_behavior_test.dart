// ignore_for_file: cascade_invocations

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ranch_components/ranch_components.dart';
import 'package:unicorn_ranch/config.dart';
import 'package:unicorn_ranch/game/entities/unicorn/behaviors/behaviors.dart';
import 'package:unicorn_ranch/game/entities/unicorn/unicorn.dart';
import 'package:unicorn_ranch/game/game.dart';

import '../../../../helpers/helpers.dart';

class _MockEnjoymentDecreasingBehavior extends Mock
    implements EnjoymentDecreasingBehavior {}

class _MockFullnessDecreasingBehavior extends Mock
    implements FullnessDecreasingBehavior {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BlessingBloc blessingBloc;

  setUpAll(() {
    registerFallbackValue(MockBlessingEvent());
  });

  setUp(() {
    blessingBloc = MockBlessingBloc();
  });

  final flameTester = FlameTester<VeryGoodRanchGame>(
    () => VeryGoodRanchGame(blessingBloc: blessingBloc),
  );

  group('Evolution Behavior', () {
    group('evolves the unicorn', () {
      flameTester.test('from baby to kid', (game) async {
        final enjoymentDecreasingBehavior = _MockEnjoymentDecreasingBehavior();
        final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

        final evolvingBehavior = EvolvingBehavior();

        final unicorn = Unicorn.test(
          position: Vector2.zero(),
          behaviors: [
            enjoymentDecreasingBehavior,
            fullnessDecreasingBehavior,
            evolvingBehavior,
          ],
        );
        await game.ready();
        await game.background.ensureAdd(unicorn);

        expect(unicorn.evolutionStage, UnicornEvolutionStage.baby);
        unicorn.timesFed = Config.timesThatMustBeFedToEvolve;

        unicorn.enjoyment.value = 1;
        unicorn.fullness.value = 1;

        game.update(0);
        await game.ready();

        game.update(4.2);
        await game.ready();

        expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
        expect(unicorn.timesFed, 0);

        await Future.microtask(() {
          verify(
            () => blessingBloc.add(
              const UnicornEvolved(to: UnicornEvolutionStage.child),
            ),
          ).called(1);
        });
      });

      flameTester.test('from kid to teen', (game) async {
        final enjoymentDecreasingBehavior = _MockEnjoymentDecreasingBehavior();
        final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

        final evolvingBehavior = EvolvingBehavior();

        final unicorn = Unicorn.test(
          position: Vector2.zero(),
          unicornComponent: ChildUnicornComponent(),
          behaviors: [
            evolvingBehavior,
            enjoymentDecreasingBehavior,
            fullnessDecreasingBehavior,
          ],
        );
        await game.ready();
        await game.background.ensureAdd(unicorn);
        await game.ready();

        expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
        unicorn.timesFed = Config.timesThatMustBeFedToEvolve;
        unicorn.enjoyment.value = 1;
        unicorn.fullness.value = 1;

        game.update(0);
        await game.ready();

        game.update(4.2);
        await game.ready();

        expect(unicorn.evolutionStage, UnicornEvolutionStage.teen);
        expect(unicorn.timesFed, 0);

        await Future.microtask(() {
          verify(
            () => blessingBloc.add(
              const UnicornEvolved(to: UnicornEvolutionStage.teen),
            ),
          ).called(1);
        });
      });

      flameTester.test('from teen to adult', (game) async {
        final enjoymentDecreasingBehavior = _MockEnjoymentDecreasingBehavior();
        final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

        final evolvingBehavior = EvolvingBehavior();

        final unicorn = Unicorn.test(
          position: Vector2.zero(),
          unicornComponent: TeenUnicornComponent(),
          behaviors: [
            evolvingBehavior,
            enjoymentDecreasingBehavior,
            fullnessDecreasingBehavior,
          ],
        );
        await game.ready();
        await game.background.ensureAdd(unicorn);
        game.update(5);

        expect(unicorn.evolutionStage, UnicornEvolutionStage.teen);
        unicorn.timesFed = Config.timesThatMustBeFedToEvolve;

        unicorn.enjoyment.value = 1;
        unicorn.fullness.value = 1;

        game.update(0);
        await game.ready();

        game.update(4.2);
        await game.ready();

        expect(unicorn.evolutionStage, UnicornEvolutionStage.adult);
        expect(unicorn.timesFed, 0);

        await Future.microtask(() {
          verify(
            () => blessingBloc.add(
              const UnicornEvolved(to: UnicornEvolutionStage.adult),
            ),
          ).called(1);
        });
      });

      flameTester.test(
        'stops evolution when reaches the adult stage',
        (game) async {
          final enjoymentDecreasingBehavior =
              _MockEnjoymentDecreasingBehavior();
          final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

          final evolvingBehavior = EvolvingBehavior();

          final unicorn = Unicorn.test(
            position: Vector2.zero(),
            unicornComponent: AdultUnicornComponent(),
            behaviors: [
              evolvingBehavior,
              enjoymentDecreasingBehavior,
              fullnessDecreasingBehavior,
            ],
          );
          await game.ready();
          await game.background.ensureAdd(unicorn);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.adult);
          unicorn.timesFed = Config.timesThatMustBeFedToEvolve;

          unicorn.enjoyment.value = 1;
          unicorn.fullness.value = 1;

          game.update(0);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.adult);
          expect(unicorn.timesFed, Config.timesThatMustBeFedToEvolve);

          await Future.microtask(() {
            verifyNever(
              () => blessingBloc.add(any(that: isA<UnicornEvolved>())),
            );
          });
        },
      );

      flameTester.test(
        'stops evolution when the unicorn is not fed enough',
        (game) async {
          final enjoymentDecreasingBehavior =
              _MockEnjoymentDecreasingBehavior();
          final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

          final evolvingBehavior = EvolvingBehavior();

          final unicorn = Unicorn.test(
            position: Vector2.zero(),
            unicornComponent: ChildUnicornComponent(),
            behaviors: [
              evolvingBehavior,
              enjoymentDecreasingBehavior,
              fullnessDecreasingBehavior,
            ],
          );
          await game.ready();
          await game.background.ensureAdd(unicorn);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
          unicorn.timesFed = 0;

          unicorn.enjoyment.value = 1;
          unicorn.fullness.value = 1;

          game.update(0);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
          expect(unicorn.timesFed, 0);

          await Future.microtask(() {
            verifyNever(
              () => blessingBloc.add(any(that: isA<UnicornEvolved>())),
            );
          });
        },
      );

      flameTester.test(
        'stops evolution when the unicorn is not happy enough',
        (game) async {
          final enjoymentDecreasingBehavior =
              _MockEnjoymentDecreasingBehavior();
          final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

          final evolvingBehavior = EvolvingBehavior();

          final unicorn = Unicorn.test(
            position: Vector2.zero(),
            unicornComponent: ChildUnicornComponent(),
            behaviors: [
              evolvingBehavior,
              enjoymentDecreasingBehavior,
              fullnessDecreasingBehavior,
            ],
          );
          await game.ready();
          await game.background.ensureAdd(unicorn);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
          unicorn.timesFed = Config.timesThatMustBeFedToEvolve;
          unicorn.enjoyment.value = 0;
          unicorn.fullness.value = 0;

          game.update(0);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
          expect(unicorn.timesFed, Config.timesThatMustBeFedToEvolve);

          await Future.microtask(() {
            verifyNever(
              () => blessingBloc.add(any(that: isA<UnicornEvolved>())),
            );
          });
        },
      );

      flameTester.test(
        'stops evolution when there is a evolution already scheduled',
        (game) async {
          final enjoymentDecreasingBehavior =
              _MockEnjoymentDecreasingBehavior();
          final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

          final evolvingBehavior = EvolvingBehavior();

          final unicorn = Unicorn.test(
            position: Vector2.zero(),
            unicornComponent: ChildUnicornComponent(),
            behaviors: [
              evolvingBehavior,
              enjoymentDecreasingBehavior,
              fullnessDecreasingBehavior,
            ],
          );
          await game.ready();
          await game.background.ensureAdd(unicorn);
          await game.ready();

          expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
          unicorn.timesFed = Config.timesThatMustBeFedToEvolve;
          unicorn.enjoyment.value = 1;
          unicorn.fullness.value = 1;

          unicorn.waitingCurrentAnimationToEvolve = true;

          game.update(0);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
          expect(unicorn.timesFed, 5);
          verifyNever(() => blessingBloc.add(any(that: isA<UnicornEvolved>())));
        },
      );
    });

    group('on evolution', () {
      flameTester.test(
        'resets enjoyment and fullness factors to full',
        (game) async {
          final enjoymentDecreasingBehavior =
              _MockEnjoymentDecreasingBehavior();
          final fullnessDecreasingBehavior = _MockFullnessDecreasingBehavior();

          final evolvingBehavior = EvolvingBehavior();

          final unicorn = Unicorn.test(
            position: Vector2.zero(),
            unicornComponent: ChildUnicornComponent(),
            behaviors: [
              evolvingBehavior,
              enjoymentDecreasingBehavior,
              fullnessDecreasingBehavior,
            ],
          );
          await game.ready();
          await game.background.ensureAdd(unicorn);

          expect(unicorn.evolutionStage, UnicornEvolutionStage.child);
          unicorn.timesFed = Config.timesThatMustBeFedToEvolve;

          // Setting happiness to above the threshold, but not full
          unicorn.enjoyment.value = 0.95;
          unicorn.fullness.value = 0.95;

          game.update(0);
          await game.ready();

          game.update(4.2);
          await game.ready();

          expect(unicorn.evolutionStage, UnicornEvolutionStage.teen);
          expect(unicorn.timesFed, 0);
          expect(unicorn.fullness.value, 1);
          expect(unicorn.enjoyment.value, 1);
        },
      );
    });
  });
}
