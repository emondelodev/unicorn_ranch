import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:unicorn_ranch/config.dart';
import 'package:unicorn_ranch/game/entities/unicorn/unicorn.dart';

class EnjoymentDecreasingBehavior extends Behavior<Unicorn> {
  @override
  Future<void> onLoad() async {
    await add(
      TimerComponent(
        period: Config.enjoymentDecreaseInterval,
        repeat: true,
        onTick: _decreaseEnjoyment,
      ),
    );
  }

  void _decreaseEnjoyment() {
    parent.enjoyment.decreaseBy(parent.evolutionStage.enjoymentDecreaseFactor);
  }
}

extension on UnicornEvolutionStage {
  /// Percentage that of enjoyment lost every
  /// [Config.enjoymentDecreaseInterval].
  double get enjoymentDecreaseFactor {
    switch (this) {
      case UnicornEvolutionStage.baby:
        return Config.enjoymentDecreaseFactor.baby;
      case UnicornEvolutionStage.child:
        return Config.enjoymentDecreaseFactor.child;
      case UnicornEvolutionStage.teen:
        return Config.enjoymentDecreaseFactor.teen;
      case UnicornEvolutionStage.adult:
        return Config.enjoymentDecreaseFactor.adult;
    }
  }
}
