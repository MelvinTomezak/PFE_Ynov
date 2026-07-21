/// Validateurs de saisie, volontairement isolés en fonctions pures.
///
/// Deux bénéfices :
///  - ils sont directement testables unitairement (compétence C2.2.2) ;
///  - ils centralisent la validation des entrées utilisateur, première
///    ligne de défense contre les injections (OWASP A03:2021).
///
/// Chaque validateur renvoie `null` si la valeur est valide, ou un message
/// d'erreur (String) à afficher sous le champ.
class Validators {
  const Validators._();

  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  /// Valide une adresse e-mail.
  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'L\'adresse e-mail est requise.';
    }
    if (!_emailRegExp.hasMatch(input)) {
      return 'Adresse e-mail invalide.';
    }
    return null;
  }

  /// Valide un mot de passe (minimum 8 caractères, au moins une lettre
  /// et un chiffre).
  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) {
      return 'Le mot de passe est requis.';
    }
    if (input.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    final hasLetter = input.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = input.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasDigit) {
      return 'Le mot de passe doit contenir au moins une lettre et un chiffre.';
    }
    return null;
  }

  /// Valide la confirmation de mot de passe.
  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return 'La confirmation est requise.';
    }
    if (value != original) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}
