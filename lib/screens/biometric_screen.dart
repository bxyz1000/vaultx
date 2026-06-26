import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _message = 'Use fingerprint or PIN to unlock VaultX';

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _message = 'Waiting for authentication...';
    });

    try {
      final bool canAuth =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuth) {
        setState(() {
          _message = 'Biometrics not available on this device';
          _isAuthenticating = false;
        });
        return;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Unlock VaultX to access your credentials',
        options: const AuthenticationOptions(
          biometricOnly: false, // allows PIN fallback too
          stickyAuth: true,
        ),
      );

      if (authenticated && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          _message = 'Authentication failed. Try again.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFFFBE0B).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 72,
                color: Color(0xFFFFBE0B),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'VaultX',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 40),
            if (!_isAuthenticating)
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFBE0B),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )
            else
              const CircularProgressIndicator(
                color: Color(0xFFFFBE0B),
              ),
          ],
        ),
      ),
    );
  }
}
