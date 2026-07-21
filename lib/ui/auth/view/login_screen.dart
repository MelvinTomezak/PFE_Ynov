import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../common/neon_text.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'signup_screen.dart';

/// Écran de connexion.
///
/// Accessibilité (RGAA/WCAG) : labels explicites, erreurs annoncées,
/// cibles tactiles ≥ 48px (via le thème).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(viewModel.errorMessage ?? 'Échec de la connexion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
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
                  Center(
                    child: Semantics(
                      header: true,
                      child: const NeonText('STYMA', fontSize: 44, glow: 22),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                    autofillHints: const [AutofillHints.password],
                    decoration:
                        const InputDecoration(labelText: 'Mot de passe'),
                    validator: Validators.password,
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
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            ),
                    child: const Text('Pas encore de compte ? S\'inscrire'),
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
