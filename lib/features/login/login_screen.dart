import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import '../home/home_screen.dart';
import '../home/islam_home_screen.dart';
import '../home/imam_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter both email and password');
      return;
    }

    if (!isValidEmail(email)) {
      _showMessage('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔐 Sign in with Firebase
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final userId = userCred.user!.uid;

      // 📥 Get user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _showMessage('User data not found in database.');
        return;
      }

      final userData = userDoc.data()!;
      final String religion = userData['religion'] ?? '';
      final String role = userData['role'] ?? '';
      final String name = userData['name'] ?? 'User';

      // 🎯 Route based on role + religion
      if (role == 'Imam') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ImamHomeScreen(imamName: name)),
        );
      } else if (religion == 'Islam') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IslamHomeScreen(studentName: name)),
        );
      } else if (religion == 'Christianity') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(studentName: name)),
        );
      } else {
        _showMessage('Unrecognized religion or role.');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage('Login failed: ${e.message}');
    } catch (e) {
      _showMessage('Unexpected error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: Text(_isLoading ? 'Logging in...' : 'Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
