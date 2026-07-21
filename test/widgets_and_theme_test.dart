import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styma/core/theme/app_colors.dart';
import 'package:styma/ui/common/error_state.dart';

void main() {
  group('AppColors', () {
    test('définit un fond noir et les accents néon attendus', () {
      // Vérifie les constantes visuelles sans déclencher le chargement réseau
      // des Google Fonts, qui est volontairement bloqué par Flutter Test.
      expect(AppColors.background, const Color(0xFF000000));
      expect(AppColors.primary, const Color(0xFF38BDF8));
      expect(AppColors.danger, const Color(0xFFFF6B6B));
    });

    test('construit le dégradé dans le bon ordre', () {
      // Vérifie que le dégradé signature va bien du bleu vers l'indigo.
      expect(AppColors.neonGradient.colors, [
        AppColors.primary,
        AppColors.secondary,
      ]);
      expect(AppColors.neonGradient.begin, Alignment.topLeft);
      expect(AppColors.neonGradient.end, Alignment.bottomRight);
    });
  });

  testWidgets('ErrorState affiche le message et relance l’action',
      (tester) async {
    // Vérifie le rendu d'une erreur et le branchement du bouton Réessayer.
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ErrorState(
          message: 'Erreur contrôlée',
          onRetry: () => retries++,
        ),
      ),
    );
    expect(find.text('Erreur contrôlée'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    expect(retries, 1);
  });
}
