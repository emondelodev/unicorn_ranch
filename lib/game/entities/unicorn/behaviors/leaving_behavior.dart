import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:unicorn_ranch/config.dart';
import 'package:unicorn_ranch/game/bloc/blessing/blessing_bloc.dart';
import 'package:unicorn_ranch/game/entities/entities.dart';

class LeavingBehavior extends Behavior<Unicorn>
    with FlameBlocReader<BlessingBloc, BlessingState> {
  static const double leavingAnimationDuration = 1;
  static const Curve leavingAnimationCurve = Curves.easeIn;

  EffectController? _effectController;

  @override
  void update(double dt) {
    if (parent.happiness <= Config.happinessThresholdToLeave &&
        !parent.isLeaving) {
      _startLeaveAnimation();
    }

    if (_effectController?.completed == true) {
      parent.removeFromParent();
    }
  }

  void _startLeaveAnimation() {
    final effectController = _effectController = CurvedEffectController(
      leavingAnimationDuration,
      leavingAnimationCurve,
    );

    bloc.add(UnicornDespawned(parent.evolutionStage));
    parent.isLeaving = true;

    parent.unicornComponent
      ..add(OpacityEffect.fadeOut(effectController))
      ..add(MoveByEffect(Vector2(0, -100), effectController));
  }
}
