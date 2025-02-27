import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/animation.dart';
import 'package:ranch_components/ranch_components.dart';
import 'package:unicorn_ranch/game/behaviors/behaviors.dart';
import 'package:unicorn_ranch/game/entities/entities.dart';
import 'package:unicorn_ranch/game/unicorn_ranch_game.dart';

class DraggingBehavior
    extends ThresholdDraggableBehavior<Unicorn, VeryGoodRanchGame> {
  DraggingBehavior();

  @override
  double get threshold => 40;

  Vector2? positionBefore;
  Anchor? anchorBefore;
  bool? goingRight;

  RotateEffect? currentRotateEffect;
  double? currentDestination;

  void _addRotateEffect(double to) {
    currentRotateEffect?.pause();
    currentRotateEffect?.removeFromParent();
    parent.add(
      currentRotateEffect = RotateEffect.to(
        to * degrees2Radians,
        EffectController(
          duration: 0.1,
        ),
      )..onComplete = () => currentRotateEffect = null,
    );
  }

  ScaleEffect? currentScaleEffect;

  void _addScaleEffect(Vector2 to, [VoidCallback? onComplete]) {
    currentScaleEffect?.pause();
    currentScaleEffect?.removeFromParent();
    parent.add(
      currentScaleEffect = ScaleEffect.to(
        to,
        EffectController(
          duration: 0.1,
        ),
      )..onComplete = () {
          currentScaleEffect = null;
          onComplete?.call();
        },
    );
  }

  OpacityEffect? currentOpacityEffect;

  void _addOpacityEffect(double to) {
    currentOpacityEffect?.pause();
    currentOpacityEffect?.removeFromParent();
    parent.unicornComponent.add(
      currentOpacityEffect = OpacityEffect.to(
        to,
        EffectController(
          duration: 0.4,
        ),
      )..onComplete = () {
          currentOpacityEffect = null;
        },
    );
  }

  @override
  bool onReallyDragStart(DragStartInfo info) {
    anchorBefore = parent.anchor;

    parent
      ..setUnicornState(UnicornState.idle)
      ..beingDragged = true
      ..anchor = Anchor.center;

    final localEventPosition =
        parent.transform.globalToLocal(info.eventPosition.game);

    parent
      ..position = parent.positionOf(localEventPosition)
      ..isGaugeVisible = false
      ..overridePriority = 1000;

    _addScaleEffect(Vector2.all(0.7));
    _addOpacityEffect(0.8);

    positionBefore = parent.position.clone();

    return false;
  }

  @override
  bool onReallyDragUpdate(DragUpdateInfo info) {
    final delta = info.delta.game;

    if (delta.x < 0 && goingRight != true) {
      goingRight = true;
      _addRotateEffect(-15);
    }
    if (delta.x > 0 && goingRight != false) {
      goingRight = false;
      _addRotateEffect(15);
    }

    parent.position.add(delta);
    _clampUnicorn();
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    super.onDragEnd(info);
    _finishDragging();
    return false;
  }

  @override
  bool onDragCancel() {
    super.onDragCancel();
    _finishDragging();
    return false;
  }

  void _finishDragging() {
    goingRight = null;
    parent
      ..beingDragged = false
      ..isGaugeVisible = true
      ..overridePriority = null;

    _addScaleEffect(Vector2.all(1), () {
      final anchorBefore = this.anchorBefore;
      if (anchorBefore != null) {
        parent
          ..position = parent.positionOfAnchor(anchorBefore)
          ..anchor = anchorBefore;

        this.anchorBefore = null;
      }
    });
    _addRotateEffect(0);
    _addOpacityEffect(1);

    _dropUnicorn();

    positionBefore = null;
  }

  void _dropUnicorn() {
    final unicornBottom = parent.positionOfAnchor(Anchor.bottomCenter).y;

    final yDelta = (parent.position.y - positionBefore!.y).abs();

    final dropTargetY = min<double>(
      30,
      gameRef.background.pastureField.bottom - unicornBottom,
    );

    if (dropTargetY > 10 && yDelta > 30) {
      parent.add(
        MoveByEffect(
          Vector2(0, dropTargetY),
          EffectController(
            duration: 0.3,
            curve: Curves.bounceOut,
          ),
        ),
      );
    } else {
      parent.position.add(Vector2(0, dropTargetY));
    }
  }

  void _clampUnicorn() {
    final pastureField = gameRef.background.pastureField;
    final unicornX =
        parent.position.x.clamp(pastureField.left, pastureField.right);

    final unicornY =
        parent.position.y.clamp(pastureField.top, pastureField.bottom);

    parent.position.x = unicornX;
    parent.position.y = unicornY;
  }
}
