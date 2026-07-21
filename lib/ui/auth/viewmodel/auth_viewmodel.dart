import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';

enum AuthStatus { idle, loading, error }

class AuthViewModel extends ChangeNotifier {
  final AuthDataSource _repository;

  AuthViewModel({AuthDataSource? repository})
      : _repository = repository ?? AuthRepository();

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) {
    return _run(() => _repository.signUp(
          email: email,
          password: password,
          username: username,
        ));
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<bool> deleteAccount() {
    return _run(() => _repository.deleteAccount());
  }

  Future<bool> _run(Future<void> Function() action) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _status = AuthStatus.idle;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }
}
