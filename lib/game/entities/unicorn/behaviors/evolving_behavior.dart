import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:unicorn_ranch/config.dart';
import 'package:unicorn_ranch/game/bloc/blessing/blessing_bloc.dart';
import 'package:unicorn_ranch/game/entities/entities.dart';

class EvolvingBehavior extends Behavior<Unicorn>
    with FlameBlocReader<BlessingBloc, BlessingState> {
  @override
  void update(double dt) {
    if (!shouldEvolve || parent.waitingCurrentAnimationToEvolve) {
      return;
    }

    final nextEvolutionStage = getNextEvolutionStage();
    parent.setEvolutionStage(nextEvolutionStage).then((value) {
      bloc.add(UnicornEvolved(to: nextEvolutionStage));
    });
  }

  bool get shouldEvolve {
    if (parent.evolutionStage == UnicornEvolutionStage.adult) {
      return false;
    }
    return parent.timesFed >= Config.timesThatMustBeFedToEvolve &&
        parent.happiness >= Config.happinessThresholdToEvolve;
  }

  UnicornEvolutionStage getNextEvolutionStage() {
    final currentEvolutionStage = parent.evolutionStage;
    if (currentEvolutionStage == UnicornEvolutionStage.baby) {
      return UnicornEvolutionStage.child;
    }
    if (currentEvolutionStage == UnicornEvolutionStage.child) {
      return UnicornEvolutionStage.teen;
    }
    if (currentEvolutionStage == UnicornEvolutionStage.teen) {
      return UnicornEvolutionStage.adult;
    }
    return currentEvolutionStage;
  }
}
