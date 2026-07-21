import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../viewmodel/auth_viewmodel.dart';

/// Écran d'inscription : pseudonyme, e-mail, mot de passe + confirmation.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Le pseudonyme est requis.';
    if (input.length < 2) return 'Le pseudonyme est trop court.';
    if (input.length > 20) return 'Le pseudonyme est trop long (20 max).';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé. Vérifiez votre e-mail si demandé.'),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(viewModel.errorMessage ?? 'Échec de l\'inscription')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Pseudonyme'),
                    validator: _validateUsername,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration:
                        const InputDecoration(labelText: 'Adresse e-mail'),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration:
                        const InputDecoration(labelText: 'Mot de passe'),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe'),
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _submit,
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Créer mon compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
