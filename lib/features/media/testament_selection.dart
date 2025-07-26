import 'package:flutter/material.dart';
import 'book_selection.dart';

class TestamentSelectionScreen extends StatelessWidget {
  const TestamentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF), // Soft blue background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 👇 Removed the book icon here
              const Text(
                'Choose a Testament',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 40),
              _buildTestamentButton(
                context: context,
                testament: '📜 Old Testament',
                route: 'OT',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                ),
              ),
              const SizedBox(height: 20),
              _buildTestamentButton(
                context: context,
                testament: '📖 New Testament',
                route: 'NT',
                gradient: const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestamentButton({
    required BuildContext context,
    required String testament,
    required String route,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookSelectionScreen(testament: route),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Center(
          child: Text(
            testament,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
