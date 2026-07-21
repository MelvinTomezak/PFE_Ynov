import 'package:flutter_test/flutter_test.dart';
import 'package:styma/core/utils/validators.dart';

/// Tests unitaires des validateurs de saisie.
///
/// Ces fonctions sont la première ligne de défense contre les entrées
/// invalides (et les injections). Elles sont pures, donc testables sans
/// interface ni base de données.
void main() {
  group('Validators.email', () {
    test('refuse une adresse vide', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('refuse une adresse mal formée', () {
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('abc@'), isNotNull);
      expect(Validators.email('abc@def'), isNotNull);
    });

    test('accepte une adresse valide', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('  user@example.com  '), isNull); // espaces tolérés
    });
  });

  group('Validators.password', () {
    test('refuse un mot de passe vide', () {
      expect(Validators.password(''), isNotNull);
    });

    test('refuse un mot de passe trop court', () {
      expect(Validators.password('a1b2'), isNotNull);
    });

    test('refuse un mot de passe sans chiffre', () {
      expect(Validators.password('abcdefgh'), isNotNull);
    });

    test('refuse un mot de passe sans lettre', () {
      expect(Validators.password('12345678'), isNotNull);
    });

    test('accepte un mot de passe valide', () {
      expect(Validators.password('abcd1234'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('refuse une confirmation vide', () {
      expect(Validators.confirmPassword('', 'abcd1234'), isNotNull);
    });

    test('refuse une confirmation différente', () {
      expect(Validators.confirmPassword('autre123', 'abcd1234'), isNotNull);
    });

    test('accepte une confirmation identique', () {
      expect(Validators.confirmPassword('abcd1234', 'abcd1234'), isNull);
    });
  });
}
