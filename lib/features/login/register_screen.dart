import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';
import '../home/islam_home_screen.dart';
import '../home/priest_home_screen.dart';

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
  String? _selectedRole;
  bool _isLoading = false;

  final List<String> _religions = ['Christianity', 'Islam'];
  final List<String> _roles = ['Student', 'Priest'];

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final religion = _selectedReligion;
    final role = _selectedRole;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        religion == null ||
        (_selectedReligion == 'Christianity' && _selectedRole == null)) {
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
      // Firebase Auth registration
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user info to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'religion': religion,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      // Navigate based on religion
      if (religion == 'Christianity') {
        if (_selectedRole == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(studentName: name)),
          );
        } else if (_selectedRole == 'Priest') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => PriestHomeScreen(priestName: name)),
          );
        }
      } else if (religion == 'Islam') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IslamHomeScreen(studentName: name)),
        );
      } else {
        // fallback
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (e) {
      debugPrint('Firestore FirebaseException: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database error: ${e.message}')),
      );
    } catch (e) {
      debugPrint('General error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
              decoration: const InputDecoration(labelText: 'Password'),
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
                  _selectedRole = null; // Reset role if religion changes
                });
              },
              decoration: const InputDecoration(labelText: 'Select Religion'),
            ),
            const SizedBox(height: 16),
            if (_selectedReligion == 'Christianity')
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                decoration: const InputDecoration(labelText: 'Select Role'),
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
