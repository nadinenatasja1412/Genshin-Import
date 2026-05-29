import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_genshin_import/services/authServices.dart';
import 'package:flutter_genshin_import/screens/ui/login.dart';
import 'package:flutter_genshin_import/screens/ui/weapon-list.dart';
import 'package:flutter_genshin_import/theme/appTheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..init(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Import',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _SplashGate(),
    );
  }
}

/// Decides whether to show Login or the main screen based on saved session.
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // AuthProvider.init() is called in the ChangeNotifierProvider above,
    // but we need to wait one frame for it to propagate.
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: AppColors.deepNavy,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  color: AppColors.darkCard,
                ),
                child: const Icon(
                  Icons.shield,
                  size: 44,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: AppColors.gold),
            ],
          ),
        ),
      );
    }

    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const WeaponListScreen() : const LoginScreen();
  }
}
