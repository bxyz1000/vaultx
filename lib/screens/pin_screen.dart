import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  const PinScreen({super.key, required this.isSetup});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _storage = const FlutterSecureStorage();
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _message = '';

  void _onKeyPress(String digit) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _message = '';
    });
    if (_enteredPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), _processPin);
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _processPin() async {
    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() {
          _confirmPin = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
          _message = 'Confirm your PIN';
        });
      } else {
        if (_enteredPin == _confirmPin) {
          await _storage.write(key: 'vault_pin', value: _enteredPin);
          _goHome();
        } else {
          setState(() {
            _enteredPin = '';
            _confirmPin = '';
            _isConfirming = false;
            _message = 'PINs did not match. Try again.';
          });
        }
      }
    } else {
      final savedPin = await _storage.read(key: 'vault_pin');
      if (_enteredPin == savedPin) {
        _goHome();
      } else {
        setState(() {
          _enteredPin = '';
          _message = 'Wrong PIN. Try again.';
        });
      }
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 64, color: Color(0xFF6C63FF)),
            const SizedBox(height: 24),
            Text(
              widget.isSetup
                  ? (_isConfirming ? 'Confirm PIN' : 'Set Your PIN')
                  : 'Enter PIN',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _message.isEmpty
                  ? (widget.isSetup && !_isConfirming
                      ? 'Choose a 4-digit PIN'
                      : '')
                  : _message,
              style: TextStyle(
                color: _message.contains('match') || _message.contains('Wrong')
                    ? Colors.redAccent
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _enteredPin.length
                        ? const Color(0xFF6C63FF)
                        : Colors.grey.shade700,
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 80, height: 80);
            return GestureDetector(
              onTap: () => key == 'del' ? _onDelete() : _onKeyPress(key),
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1E2E),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: key == 'del'
                      ? const Icon(Icons.backspace_outlined,
                          color: Colors.white70)
                      : Text(
                          key,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
