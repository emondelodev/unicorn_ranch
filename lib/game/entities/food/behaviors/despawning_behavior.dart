import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:unicorn_ranch/game/entities/entities.dart';

class DespawningBehavior extends Behavior<Food> {
  DespawningBehavior({
    required this.despawnTime,
  });

  /// The amount of time in seconds before the food despawns.
  final double despawnTime;

  TimerComponent? _timer;

  @override
  Future<void> onLoad() async {
    await add(_timer = TimerComponent(period: despawnTime, onTick: onDespawn));
  }

  void onDespawn() {
    parent.removeFromParent();
  }

  @override
  void update(double dt) {
    // If it is currently being dragged stop the timer
    if (parent.beingDragged == true) {
      _timer?.timer.stop();
    } else {
      if (!(_timer?.timer.isRunning() ?? false)) {
        _timer?.timer.start();
      }
    }

    super.update(dt);
  }
}
