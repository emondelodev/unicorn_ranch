import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:ranch_sounds/ranch_sounds.dart';
import 'package:unicorn_ranch/game/bloc/bloc.dart';
import 'package:unicorn_ranch/game_menu/game_menu.dart';
import 'package:unicorn_ranch/loading/loading.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockBlessingBloc extends MockBloc<BlessingEvent, BlessingState>
    implements BlessingBloc {}

class MockBlessingEvent extends Mock implements BlessingEvent {}

class MockRandom extends Mock implements Random {}

class MockPreloadCubit extends MockCubit<PreloadState> implements PreloadCubit {
}

class MockRanchSoundPlayer extends Mock implements RanchSoundPlayer {}
