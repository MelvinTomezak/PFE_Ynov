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
      // Vérifie que null et une chaîne vide déclenchent une erreur obligatoire.
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('refuse une adresse mal formée', () {
      // Vérifie plusieurs adresses auxquelles il manque un domaine valide.
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('abc@'), isNotNull);
      expect(Validators.email('abc@def'), isNotNull);
    });

    test('accepte une adresse valide', () {
      // Vérifie une adresse standard et la suppression des espaces extérieurs.
      expect(Validators.email('user@example.com'), isNull);
      expect(
          Validators.email('  user@example.com  '), isNull); // espaces tolérés
    });
  });

  group('Validators.password', () {
    test('refuse un mot de passe vide', () {
      // Vérifie que le mot de passe reste obligatoire.
      expect(Validators.password(''), isNotNull);
    });

    test('refuse un mot de passe trop court', () {
      // Vérifie la longueur minimale de huit caractères.
      expect(Validators.password('a1b2'), isNotNull);
    });

    test('refuse un mot de passe sans chiffre', () {
      // Vérifie l'obligation d'inclure au moins un chiffre.
      expect(Validators.password('abcdefgh'), isNotNull);
    });

    test('refuse un mot de passe sans lettre', () {
      // Vérifie l'obligation d'inclure au moins une lettre.
      expect(Validators.password('12345678'), isNotNull);
    });

    test('accepte un mot de passe valide', () {
      // Vérifie une valeur réunissant longueur, lettres et chiffres.
      expect(Validators.password('abcd1234'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('refuse une confirmation vide', () {
      // Vérifie que la confirmation ne peut pas être omise.
      expect(Validators.confirmPassword('', 'abcd1234'), isNotNull);
    });

    test('refuse une confirmation différente', () {
      // Vérifie que les deux mots de passe doivent être identiques.
      expect(Validators.confirmPassword('autre123', 'abcd1234'), isNotNull);
    });

    test('accepte une confirmation identique', () {
      // Vérifie le cas nominal d'une confirmation correcte.
      expect(Validators.confirmPassword('abcd1234', 'abcd1234'), isNull);
    });
  });

  group('Validators.username', () {
    test('refuse un pseudonyme vide', () {
      // Vérifie les valeurs nulles, vides ou composées uniquement d'espaces.
      expect(Validators.username(null), isNotNull);
      expect(Validators.username('   '), isNotNull);
    });

    test('refuse un pseudonyme trop court', () {
      // Vérifie la limite basse de deux caractères.
      expect(Validators.username('A'), isNotNull);
    });

    test('refuse un pseudonyme trop long', () {
      // Vérifie la limite haute de vingt caractères.
      expect(Validators.username(List.filled(21, 'a').join()), isNotNull);
    });

    test('accepte les deux longueurs limites', () {
      // Vérifie que les bornes 2 et 20 sont incluses.
      expect(Validators.username('AB'), isNull);
      expect(Validators.username(List.filled(20, 'a').join()), isNull);
    });
  });
}
