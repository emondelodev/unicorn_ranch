// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ranch_sounds/ranch_sounds.dart';
import 'package:unicorn_ranch/app/app.dart';
import 'package:unicorn_ranch/game/game.dart';
import 'package:unicorn_ranch/game_menu/game_menu.dart';
import 'package:unicorn_ranch/loading/loading.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  setUp(() {
    HydratedBloc.storage = MockStorage();
  });

  group('App', () {
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.byType(AppView), findsOneWidget);
    });

    testWidgets('renders MaterialApp', (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.byType(MaterialApp), findsOneWidget);
      final title = find.byType(Title).evaluate().first.widget as Title;
      expect(title.title, 'Very Good Ranch');
    });
  });

  group('AppView', () {
    testWidgets('renders LoadingPage', (tester) async {
      final preloadCubit = MockPreloadCubit();
      final initialState = PreloadState.initial();
      final sounds = MockRanchSoundPlayer();
      when(() => preloadCubit.sounds).thenReturn(sounds);
      when(() => sounds.play(RanchSound.sunsetMemory))
          .thenAnswer((Invocation invocation) async {});
      when(() => sounds.setVolume(RanchSound.sunsetMemory, any()))
          .thenAnswer((Invocation invocation) async {});
      when(() => sounds.stop(RanchSound.sunsetMemory))
          .thenAnswer((Invocation invocation) async {});

      whenListen(
        preloadCubit,
        Stream.fromIterable([initialState]),
        initialState: initialState,
      );

      final settingsBloc = MockSettingsBloc();

      whenListen(
        settingsBloc,
        const Stream<SettingsState>.empty(),
        initialState: SettingsState(),
      );

      when(preloadCubit.loadSequentially).thenAnswer((_) async {});
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<BlessingBloc>.value(value: MockBlessingBloc()),
            BlocProvider<PreloadCubit>.value(value: preloadCubit),
          ],
          child: AppView(),
        ),
      );
      await tester.pump(Duration(milliseconds: 500));
      expect(find.byType(LoadingPage), findsOneWidget);
    });
  });
}
