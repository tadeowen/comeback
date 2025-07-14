import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IslamPrayerRequest extends StatefulWidget {
  const IslamPrayerRequest({super.key});

  @override
  State<IslamPrayerRequest> createState() => _IslamPrayerRequestState();
}

class _IslamPrayerRequestState extends State<IslamPrayerRequest> {
  final TextEditingController _messageController = TextEditingController();
  String? selectedImamId;
  String? selectedCategory;
  List<Map<String, dynamic>> imams = [];
  List<String> categories = [];
  String visibilityOption = 'Anonymous';
  bool imamHasNoResponsibilities = false;

  @override
  void initState() {
    super.initState();
    fetchImams();
    fetchCategoriesForImam(null);
  }

  Future<void> fetchImams() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Imam')
        .where('religion', isEqualTo: 'Islam')
        .get();

    setState(() {
      imams = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  Future<void> fetchCategoriesForImam(String? imamId) async {
    Query query = FirebaseFirestore.instance.collection('imamAppointments');
    if (imamId != null) {
      query = query.where('imamId', isEqualTo: imamId);
    }

    final snapshot = await query.get();

    final fetchedCategories = snapshot.docs
        .map((doc) => doc['responsibility'] as String? ?? '')
        .where((resp) => resp.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      categories = fetchedCategories;
      selectedCategory = null;
      imamHasNoResponsibilities = (imamId != null && fetchedCategories.isEmpty);
    });
  }

  Future<void> sendPrayerRequest() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a prayer request")),
      );
      return;
    }

    if (selectedImamId != null &&
        (selectedCategory == null || selectedCategory!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category for the Imam")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (imams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Imams available.")),
      );
      return;
    }

    final targetImamId =
        selectedImamId ?? imams[Random().nextInt(imams.length)]['id'];

    String? confirmationDay;
    String? confirmationTime;

    // 🕐 Try to find matching appointment based on category
    if (selectedCategory != null) {
      final appointments = await FirebaseFirestore.instance
          .collection('imamAppointments')
          .where('imamId', isEqualTo: targetImamId)
          .where('responsibility', isEqualTo: selectedCategory)
          .get();

      if (appointments.docs.isNotEmpty) {
        final data = appointments.docs.first.data();
        confirmationDay = data['day'];
        confirmationTime = data['time'];
      }
    }

    final requestData = {
      'studentId': user.uid,
      'imamId': targetImamId,
      'message': _messageController.text.trim(),
      'timestamp': Timestamp.now(),
      'visibility': visibilityOption,
      if (visibilityOption == 'Public') ...{
        'studentName': user.displayName ?? 'Unknown',
        'studentEmail': user.email ?? 'Not available',
      },
      if (selectedCategory != null) 'category': selectedCategory,
      if (confirmationDay != null) 'confirmationDay': confirmationDay,
      if (confirmationTime != null) 'confirmationTime': confirmationTime,
    };

    await FirebaseFirestore.instance.collection('dua_request').add(requestData);

    _messageController.clear();
    setState(() {
      selectedImamId = null;
      selectedCategory = null;
      categories = [];
      imamHasNoResponsibilities = false;
      visibilityOption = 'Anonymous';
    });

    fetchCategoriesForImam(null);

    String confirmationMessage = (confirmationDay != null &&
            confirmationTime != null)
        ? "Request sent! Your appointment is on $confirmationDay at $confirmationTime."
        : "Prayer request sent!";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(confirmationMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal.shade700;
    final Color lightGreen = Colors.teal.shade50;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🕌 Prayer Request"),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          color: lightGreen,
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Send Your Prayer Request",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Imam Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Select Imam",
                      prefixIcon: Icon(Icons.person, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: lightGreen,
                    ),
                    value: selectedImamId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Any available Imam"),
                      ),
                      ...imams.map(
                        (imam) => DropdownMenuItem(
                          value: imam['id'],
                          child: Text(imam['name']),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedImamId = value;
                        selectedCategory = null;
                        categories = [];
                        imamHasNoResponsibilities = false;
                      });
                      fetchCategoriesForImam(value);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Select Category",
                      prefixIcon: Icon(Icons.category, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: lightGreen,
                    ),
                    value: selectedCategory,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (imamHasNoResponsibilities || categories.isEmpty)
                        ? null
                        : (val) {
                            setState(() {
                              selectedCategory = val;
                            });
                          },
                    disabledHint: imamHasNoResponsibilities
                        ? const Text("The chosen Imam has no responsibilities")
                        : const Text("No categories available"),
                  ),
                  const SizedBox(height: 20),

                  // Visibility Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Choose Visibility",
                      prefixIcon: Icon(Icons.visibility, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: lightGreen,
                    ),
                    value: visibilityOption,
                    items: const [
                      DropdownMenuItem(
                          value: 'Anonymous', child: Text("Anonymous")),
                      DropdownMenuItem(value: 'Public', child: Text("Public")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        visibilityOption = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Prayer Message TextField
                  TextField(
                    controller: _messageController,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: "Description",
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.message, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: lightGreen,
                      hintText: "Write your prayer request here...",
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Send Button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: sendPrayerRequest,
                      icon: const Icon(Icons.send),
                      label: const Text(
                        "Send ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                      ),
                    ),
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
