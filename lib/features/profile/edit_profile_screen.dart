// lib/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final DocumentSnapshot initialData;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.initialData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  File? _imageFile;
  String? _existingPhotoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData.data() as Map<String, dynamic>? ?? {};
    _nameController = TextEditingController(text: data['name'] ?? '');
    _ageController =
        TextEditingController(text: (data['age'] ?? '').toString());
    _existingPhotoUrl = data['photoUrl'];
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Take a picture'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadImage(String uid) async {
    if (_imageFile == null) return _existingPhotoUrl;

    final ref = FirebaseStorage.instance.ref().child('profile_pics/$uid.jpg');
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final photoUrl = await _uploadImage(widget.userId);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'photoUrl': photoUrl,
    });

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_existingPhotoUrl != null &&
                                          _existingPhotoUrl!.isNotEmpty)
                                      ? NetworkImage(_existingPhotoUrl!)
                                      : const AssetImage(
                                              'assets/images/placeholder_avatar.png')
                                          as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.blue),
                                onPressed: _showImageSourceDialog,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) =>
                            value!.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'),
                        validator: (value) {
                          final age = int.tryParse(value!);
                          if (age == null || age <= 0) {
                            return 'Enter valid age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
