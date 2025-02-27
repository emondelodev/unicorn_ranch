import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:unicorn_ranch/game/entities/entities.dart';

class DraggingBehavior extends DraggableBehavior<Food> with HasGameRef {
  @override
  bool onDragStart(DragStartInfo info) {
    parent
      ..wasDragged = false
      ..beingDragged = true
      ..overridePriority = 10001;
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    parent.position.add(info.delta.game);
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    // Check if we are colliding with something, if we aren't then we are
    // gonna check if we are being within the bounds of a unicorn.
    if (!(parent.firstChild<RectangleHitbox>()?.isColliding ?? false)) {
      final unicorns =
          gameRef.componentsAtPoint(parent.center).whereType<Unicorn>();

      final unicorn = unicorns.isNotEmpty ? unicorns.first : null;
      if (unicorn != null && !parent.isRemoving) {
        unicorn.feed(parent);
      }
    }

    _wasDraggedBefore();
    _finishDragging();

    return false;
  }

  @override
  bool onDragCancel() {
    _finishDragging();

    return false;
  }

  void _finishDragging() {
    parent
      ..overridePriority = null
      ..beingDragged = false;
  }

  void _wasDraggedBefore() {
    firstChild<TimerComponent>()?.removeFromParent();

    parent.wasDragged = true;
    add(
      TimerComponent(
        period: 5,
        onTick: () => parent.wasDragged = false,
        removeOnFinish: true,
      ),
    );
  }
}
