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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final religion = _selectedReligion;

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
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'religion': religion,
        'createdAt': Timestamp.now(),
      });

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
      } else {
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
    const Color backgroundColor = Color(0xFFFFF8E1); // soft golden
    const Color appBarColor = Color(0xFF6A1B1A); // deep maroon
    const Color inputBorderColor = Color(0xFFD2691E); // rusty orange
    const Color buttonColor = Color(0xFFD2691E); // rusty orange
    const Color textColor = Color(0xFF4B1D1D); // earthy dark
    const Color labelColor = Color(0xFF5D4037); // warm brown

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text('Register', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: appBarColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: appBarColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: appBarColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReligion,
              dropdownColor: backgroundColor,
              iconEnabledColor: inputBorderColor,
              style: const TextStyle(color: textColor),
              items: _religions
                  .map((religion) => DropdownMenuItem(
                        value: religion,
                        child: Text(religion),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedReligion = value),
              decoration: InputDecoration(
                labelText: 'Select Religion',
                labelStyle: const TextStyle(color: labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: appBarColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(_isLoading ? 'Registering...' : 'Register'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: appBarColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
