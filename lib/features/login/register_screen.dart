import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../home/home_screen.dart';
import '../home/islam_home_screen.dart';
import '../home/priest_home_screen.dart';
import '../home/imam_home_screen.dart';

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
  bool _obscurePassword = true;

  File? _pickedImage;

  final List<String> _religions = ['Christianity', 'Islam'];
  final List<String> _christianRoles = ['Student', 'Priest'];
  final List<String> _islamRoles = ['Student', 'Imam'];

  List<String> get _currentRoles {
    if (_selectedReligion == 'Christianity') return _christianRoles;
    if (_selectedReligion == 'Islam') return _islamRoles;
    return [];
  }

  // Password strength variables
  double _passwordStrength = 0;
  String _passwordFeedback = '';
  Color _passwordColor = Colors.grey;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    return emailRegex.hasMatch(email);
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\\$&*~]'))) strength += 0.25;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfilePicture(String userId) async {
    if (_pickedImage == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('$userId.jpg');

      await ref.putFile(_pickedImage!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Failed to upload profile picture: \$e');
      return null;
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final religion = _selectedReligion;
    final role = _selectedRole;

    if (name.isEmpty || email.isEmpty || password.isEmpty || religion == null || role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
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
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCred.user!.uid;
      final profilePicUrl = await _uploadProfilePicture(userId);

      await userCred.user!.updateDisplayName(name);
      if (profilePicUrl != null) {
        await userCred.user!.updatePhotoURL(profilePicUrl);
      }
      await userCred.user!.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'religion': religion,
        'role': role,
        'profilePicUrl': profilePicUrl ?? '',
        'createdAt': Timestamp.now(),
      });

      if (religion == 'Christianity') {
        if (role == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(studentName: refreshedUser?.displayName ?? name),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PriestHomeScreen(priestName: refreshedUser?.displayName ?? name),
            ),
          );
        }
      } else {
        if (role == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => IslamHomeScreen(studentName: refreshedUser?.displayName ?? name),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ImamHomeScreen(imamName: refreshedUser?.displayName ?? name),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Email already in use.';
          break;
        case 'invalid-email':
          msg = 'Invalid email.';
          break;
        case 'weak-password':
          msg = 'Weak password.';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error: \$e')));
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
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join the ComeBack Family',
                    style: theme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“And pray for one another...” – James 5:16',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Profile picture picker
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              _pickedImage != null ? FileImage(_pickedImage!) : null,
                          child: _pickedImage == null
                              ? const Icon(Icons.person, size: 55)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.black54),
                            onPressed: _pickImage,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _checkPasswordStrength,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  if (_passwordController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: _passwordStrength,
                            color: _passwordColor,
                            backgroundColor: Colors.grey[300],
                            minHeight: 6,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _passwordFeedback,
                            style: TextStyle(
                              color: _passwordColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedReligion,
                    decoration: InputDecoration(
                      labelText: 'Select Religion',
                      prefixIcon: const Icon(Icons.self_improvement),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: _religions.map((religion) {
                      return DropdownMenuItem(value: religion, child: Text(religion));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReligion = value;
                        _selectedRole = null;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  if (_selectedReligion != null)
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Select Role',
                        prefixIcon: const Icon(Icons.emoji_people),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _currentRoles.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedRole = value),
                    ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _register,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(_isLoading ? 'Registering...' : 'Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text('Already have an account? Login'),
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
