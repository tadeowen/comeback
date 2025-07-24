// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:google_fonts/google_fonts.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _locationController = TextEditingController();

//   File? _pickedImage;
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   String? _selectedReligion;
//   String? _selectedRole;

//   final List<String> _religions = ['Christianity', 'Islam'];
//   final List<String> _christianRoles = ['Student', 'Priest'];
//   final List<String> _islamRoles = ['Student', 'Imam'];

//   double _passwordStrength = 0;
//   String _passwordFeedback = '';
//   Color _passwordColor = Colors.grey;

//   List<String> get _currentRoles {
//     if (_selectedReligion == 'Christianity') return _christianRoles;
//     if (_selectedReligion == 'Islam') return _islamRoles;
//     return [];
//   }

//   void _checkPasswordStrength(String password) {
//     double strength = 0;
//     if (password.length >= 6) strength += 0.25;
//     if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
//     if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
//     if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;

//     setState(() {
//       _passwordStrength = strength;
//       _passwordFeedback = strength == 1
//           ? 'Strong'
//           : strength >= 0.75
//               ? 'Good'
//               : strength >= 0.5
//                   ? 'Weak'
//                   : 'Very Weak';
//       _passwordColor = strength == 1
//           ? Colors.green
//           : strength >= 0.75
//               ? Colors.lightGreen
//               : strength >= 0.5
//                   ? Colors.orange
//                   : Colors.red;
//     });
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) setState(() => _pickedImage = File(picked.path));
//   }

//   Future<String?> _uploadProfilePicture(String userId) async {
//     if (_pickedImage == null) return null;
//     final ref =
//         FirebaseStorage.instance.ref('profile_pics').child('$userId.jpg');
//     await ref.putFile(_pickedImage!);
//     return await ref.getDownloadURL();
//   }

//   Future<void> _register() async {
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final location = _locationController.text.trim();

//     if ([name, email, password, _selectedReligion, _selectedRole, location]
//         .any((e) => e == null || e.toString().isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final cred = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       final uid = cred.user!.uid;
//       final photoURL = await _uploadProfilePicture(uid);

//       final userData = {
//         'name': name,
//         'email': email,
//         'religion': _selectedReligion,
//         'role': _selectedRole,
//         'profilePicUrl': photoURL ?? '',
//         'createdAt': Timestamp.now(),
//         'confirmationCode': null,
//         'assignedLeader': null,
//         'fcmToken': null,
//         'church': _selectedReligion == 'Christianity' ? location : null,
//         'mosque': _selectedReligion == 'Islam' ? location : null,
//       };

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .set(userData);

//       if (_selectedRole == 'Priest' || _selectedRole == 'Imam') {
//         await FirebaseFirestore.instance.collection('leaders').doc(uid).set({
//           'name': name,
//           'religion': _selectedReligion,
//           'role': _selectedRole,
//           'imageUrl': photoURL ?? '',
//           'preferences': [],
//           'assignedPoints': [],
//           'available': true,
//           'lastAssigned': Timestamp.now(),
//           'church': _selectedReligion == 'Christianity' ? location : null,
//           'mosque': _selectedReligion == 'Islam' ? location : null,
//         });
//       }

//       // Navigate to login screen after successful registration
//       Navigator.pushReplacementNamed(context, '/login');
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.deepPurple.shade50,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//         child: Column(
//           children: [
//             Text('Register',
//                 style: GoogleFonts.poppins(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.deepPurple,
//                 )),
//             const SizedBox(height: 8),
//             Text('Join the prayer wall',
//                 style: TextStyle(color: Colors.grey.shade700)),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.grey[300],
//                 backgroundImage:
//                     _pickedImage != null ? FileImage(_pickedImage!) : null,
//                 child: _pickedImage == null
//                     ? const Icon(Icons.person, size: 50)
//                     : null,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildTextField(_nameController, 'Full Name', Icons.person),
//             _buildTextField(_emailController, 'Email', Icons.email),
//             _buildPasswordField(),
//             _buildDropdown('Select Religion', _religions, _selectedReligion,
//                 (val) {
//               setState(() {
//                 _selectedReligion = val;
//                 _selectedRole = null;
//               });
//             }),
//             if (_selectedReligion != null)
//               _buildDropdown('Select Role', _currentRoles, _selectedRole,
//                   (val) {
//                 setState(() => _selectedRole = val);
//               }),
//             if (_selectedRole != null)
//               _buildTextField(
//                   _locationController,
//                   _selectedReligion == 'Christianity' ? 'Church' : 'Mosque',
//                   Icons.location_on),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.how_to_reg),
//               label: Text(_isLoading ? 'Registering...' : 'Register'),
//               onPressed: _isLoading ? null : _register,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(50),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextButton(
//               onPressed: () =>
//                   Navigator.pushReplacementNamed(context, '/login'),
//               child: const Text('Already have an account? Login'),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon),
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     );
//   }

//   Widget _buildPasswordField() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         TextField(
//           controller: _passwordController,
//           obscureText: _obscurePassword,
//           onChanged: _checkPasswordStrength,
//           decoration: InputDecoration(
//             labelText: 'Password',
//             prefixIcon: const Icon(Icons.lock),
//             suffixIcon: IconButton(
//               icon: Icon(
//                   _obscurePassword ? Icons.visibility_off : Icons.visibility),
//               onPressed: () =>
//                   setState(() => _obscurePassword = !_obscurePassword),
//             ),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         ),
//         const SizedBox(height: 4),
//         LinearProgressIndicator(
//           value: _passwordStrength,
//           color: _passwordColor,
//           backgroundColor: Colors.grey[300],
//           minHeight: 5,
//         ),
//         Text(_passwordFeedback, style: TextStyle(color: _passwordColor)),
//       ]),
//     );
//   }

//   Widget _buildDropdown(String label, List<String> options, String? value,
//       Function(String?) onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         items: options
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: const Icon(Icons.arrow_drop_down),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _pickedImage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _selectedReligion;
  String? _selectedRole;
  String? _selectedLocation;

  final List<String> _religions = ['Christianity', 'Islam'];
  final List<String> _christianRoles = ['Student', 'Priest'];
  final List<String> _islamRoles = ['Student', 'Imam'];
  final List<String> _locations = ['St. Francis', 'St. Augustine'];

  double _passwordStrength = 0;
  String _passwordFeedback = '';
  Color _passwordColor = Colors.grey;

  List<String> get _currentRoles {
    if (_selectedReligion == 'Christianity') return _christianRoles;
    if (_selectedReligion == 'Islam') return _islamRoles;
    return [];
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      _passwordFeedback = strength == 1
          ? 'Strong'
          : strength >= 0.75
              ? 'Good'
              : strength >= 0.5
                  ? 'Weak'
                  : 'Very Weak';
      _passwordColor = strength == 1
          ? Colors.green
          : strength >= 0.75
              ? Colors.lightGreen
              : strength >= 0.5
                  ? Colors.orange
                  : Colors.red;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<String?> _uploadProfilePicture(String userId) async {
    if (_pickedImage == null) return null;
    final ref =
        FirebaseStorage.instance.ref('profile_pics').child('$userId.jpg');
    await ref.putFile(_pickedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final location = _selectedLocation?.trim();

    if ([name, email, password, _selectedReligion, _selectedRole, location]
        .any((e) => e == null || e.toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = cred.user!.uid;
      final photoURL = await _uploadProfilePicture(uid);

      final userData = {
        'name': name,
        'email': email,
        'religion': _selectedReligion,
        'role': _selectedRole,
        'profilePicUrl': photoURL ?? '',
        'createdAt': Timestamp.now(),
        'confirmationCode': null,
        'assignedLeader': null,
        'fcmToken': null,
        'church': _selectedReligion == 'Christianity' ? location : null,
        'mosque': _selectedReligion == 'Islam' ? location : null,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      if (_selectedRole == 'Priest' || _selectedRole == 'Imam') {
        await FirebaseFirestore.instance.collection('leaders').doc(uid).set({
          'name': name,
          'religion': _selectedReligion,
          'role': _selectedRole,
          'imageUrl': photoURL ?? '',
          'preferences': [],
          'assignedPoints': [],
          'available': true,
          'lastAssigned': Timestamp.now(),
          'church': _selectedReligion == 'Christianity' ? location : null,
          'mosque': _selectedReligion == 'Islam' ? location : null,
        });
      }

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            Text('Register',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                )),
            const SizedBox(height: 8),
            Text('Join the prayer wall',
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    _pickedImage != null ? FileImage(_pickedImage!) : null,
                child: _pickedImage == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Full Name', Icons.person),
            _buildTextField(_emailController, 'Email', Icons.email),
            _buildPasswordField(),
            _buildDropdown('Select Religion', _religions, _selectedReligion,
                (val) {
              setState(() {
                _selectedReligion = val;
                _selectedRole = null;
                _selectedLocation = null;
              });
            }),
            if (_selectedReligion != null)
              _buildDropdown('Select Role', _currentRoles, _selectedRole,
                  (val) {
                setState(() {
                  _selectedRole = val;
                  _selectedLocation = null;
                });
              }),
            if (_selectedRole != null)
              _buildDropdown(
                  _selectedReligion == 'Christianity'
                      ? 'Select Church'
                      : 'Select Mosque',
                  _locations,
                  _selectedLocation,
                  (val) => setState(() => _selectedLocation = val)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.how_to_reg),
              label: Text(_isLoading ? 'Registering...' : 'Register'),
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Already have an account? Login'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: _checkPasswordStrength,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _passwordStrength,
          color: _passwordColor,
          backgroundColor: Colors.grey[300],
          minHeight: 5,
        ),
        Text(_passwordFeedback, style: TextStyle(color: _passwordColor)),
      ]),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
