import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'ui/auth/view/login_screen.dart';
import 'ui/auth/viewmodel/auth_viewmodel.dart';
import 'ui/main/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();
  runApp(const StymaApp());
}

class StymaApp extends StatelessWidget {
  const StymaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'STYMA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Aiguille l'utilisateur vers l'application ou l'écran de connexion selon
/// l'état de la session Supabase, et réagit aux changements en temps réel.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final repository = AuthRepository();

    return StreamBuilder<AuthState>(
      stream: repository.onAuthStateChange,
      builder: (context, snapshot) {
        final session = repository.currentUser;
        if (session != null) {
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
