import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';
import '../home/islam_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedReligion;
  bool _isLoading = false;

  final List<String> _religions = ['Christianity', 'Islam'];

  // Password strength variables
  double _passwordStrength = 0;
  String _passwordFeedback = '';
  Color _passwordColor = Colors.grey;

  // Helper to validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;

    String feedback;
    Color color;
    if (strength == 1) {
      feedback = "Strong";
      color = Colors.green;
    } else if (strength >= 0.75) {
      feedback = "Good";
      color = Colors.lightGreen;
    } else if (strength >= 0.5) {
      feedback = "Weak";
      color = Colors.orange;
    } else {
      feedback = "Very Weak";
      color = Colors.red;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordFeedback = feedback;
      _passwordColor = color;
    });
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final religion = _selectedReligion;

    // Basic validation with email format & password length checks
    if (name.isEmpty || email.isEmpty || password.isEmpty || religion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Register user
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'religion': religion,
        'createdAt': Timestamp.now(),
      });

      // Navigate based on religion
      if (religion == 'Christianity') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(studentName: name)),
        );
      } else if (religion == 'Islam') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IslamHomeScreen(studentName: name)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email already registered. Try logging in.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak. Please choose a stronger one.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              onChanged: _checkPasswordStrength,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            const SizedBox(height: 8),

            // Password strength bar
            LinearProgressIndicator(
              value: _passwordStrength,
              color: _passwordColor,
              backgroundColor: Colors.grey[300],
              minHeight: 5,
            ),

            // Password strength feedback text
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _passwordFeedback,
                  style: TextStyle(
                    color: _passwordColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReligion,
              items: _religions
                  .map((religion) =>
                      DropdownMenuItem(value: religion, child: Text(religion)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReligion = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Religion'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: Text(_isLoading ? 'Registering...' : 'Register'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
