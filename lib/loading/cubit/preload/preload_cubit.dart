import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:ranch_components/ranch_components.dart';
import 'package:ranch_flame/ranch_flame.dart';
import 'package:ranch_sounds/ranch_sounds.dart';
import 'package:unicorn_ranch/loading/loading.dart';

class PreloadCubit extends Cubit<PreloadState> {
  PreloadCubit(this.images, this.sounds) : super(const PreloadState.initial());

  final UnprefixedImages images;
  final RanchSoundPlayer sounds;

  /// Load items sequentially allows display of what is being loaded
  Future<void> loadSequentially() async {
    final phases = <PreloadPhase>[
      PreloadPhase(
        'sounds',
        () => sounds.preloadAssets([RanchSound.sunsetMemory]),
      ),
      PreloadPhase(
        'environment',
        () => BackgroundComponent.preloadAssets(images),
      ),
      PreloadPhase('food', () => FoodComponent.preloadAssets(images)),
      PreloadPhase(
        'baby_unicorns',
        () => BabyUnicornComponent.preloadAssets(images),
      ),
      PreloadPhase(
        'child_unicorns',
        () => ChildUnicornComponent.preloadAssets(images),
      ),
      PreloadPhase(
        'teen_unicorns',
        () => TeenUnicornComponent.preloadAssets(images),
      ),
      PreloadPhase(
        'adult_unicorns',
        () => AdultUnicornComponent.preloadAssets(images),
      ),
    ];
    emit(state.startLoading(phases.length));
    for (final phase in phases) {
      emit(state.onStartPhase(phase.label));
      // Throttle phases to take at least 1/5 seconds
      await Future.wait([
        Future.delayed(Duration.zero, phase.start),
        Future<void>.delayed(const Duration(milliseconds: 200)),
      ]);
      emit(state.onFinishPhase());
    }
  }

  @override
  Future<void> close() async {
    await sounds.dispose();
    return super.close();
  }
}

@immutable
class PreloadPhase {
  const PreloadPhase(this.label, this.start);

  final String label;
  final ValueGetter<Future<void>> start;
}
