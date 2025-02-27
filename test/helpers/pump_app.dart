// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:unicorn_ranch/game/game.dart';
import 'package:unicorn_ranch/game_menu/game_menu.dart';
import 'package:unicorn_ranch/l10n/l10n.dart';
import 'package:unicorn_ranch/loading/loading.dart';

import 'helpers.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    MockNavigator? navigator,
    MockNavigator? rootNavigator,
    SettingsBloc? settingsBloc,
    BlessingBloc? blessingBloc,
    PreloadCubit? preloadCubit,
  }) async {
    final content = MultiBlocProvider(
      providers: [
        BlocProvider.value(value: settingsBloc ?? MockSettingsBloc()),
        BlocProvider.value(value: blessingBloc ?? BlessingBloc()),
        BlocProvider.value(value: preloadCubit ?? MockPreloadCubit()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: navigator != null
            ? MockNavigatorProvider(navigator: navigator, child: widget)
            : widget,
      ),
    );

    return pumpWidget(
      rootNavigator != null
          ? MockNavigatorProvider(
              navigator: rootNavigator,
              child: content,
            )
          : content,
    );
  }
}
