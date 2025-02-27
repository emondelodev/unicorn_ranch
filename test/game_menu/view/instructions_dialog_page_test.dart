import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:unicorn_ranch/game_menu/view/instructions_dialog_page.dart';
import 'package:unicorn_ranch/game_menu/view/view.dart';
import 'package:unicorn_ranch/l10n/l10n.dart';

import '../../helpers/helpers.dart';

void main() {
  group('InstructionsDialogPage', () {
    testWidgets('renders correctly', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpApp(
        const InstructionsDialogPage(),
      );

      expect(find.text(l10n.instructions), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text(l10n.ok), findsOneWidget);

      // instructions content
      expect(find.text(l10n.instructionsText), findsOneWidget);
    });

    group('Action button', () {
      testWidgets('Pressing ok goes back to settings', (tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final navigator = MockNavigator();
        when(() => navigator.pushReplacementNamed<void, void>(any()))
            .thenAnswer((_) async {});

        await tester.pumpApp(
          const InstructionsDialogPage(),
          navigator: navigator,
        );

        await Scrollable.ensureVisible(find.text(l10n.ok).evaluate().first);

        await tester.tap(find.text(l10n.ok));

        verify(
          () => navigator.pushReplacementNamed<void, void>(
            GameMenuRoute.settings.name,
          ),
        ).called(1);
      });
    });
  });
}
