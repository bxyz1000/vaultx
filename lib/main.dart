import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/pin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/biometric_screen.dart'; // ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VaultXApp());
}

class VaultXApp extends StatelessWidget {
  const VaultXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF03DAC6),
          surface: const Color(0xFF1E1E2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF12121F),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _storage = const FlutterSecureStorage();
  bool _loading = true;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final pin = await _storage.read(key: 'vault_pin');
    setState(() {
      _hasPin = pin != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // First time user — no PIN set yet, go to PIN setup
    if (!_hasPin) {
      return const PinScreen(isSetup: true);
    }

    // PIN exists — show biometric screen (has PIN fallback button inside)
    return const BiometricScreen();
  }
}
