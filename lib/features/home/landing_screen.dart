import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late Timer _timer;
  String _currentTime = '';
  String _greeting = '';
  bool _visible = false; // Controls fade-in of main content
  bool _showButton = false; // Controls button animation

  @override
  void initState() {
    super.initState();
    _updateTime();
    _updateGreeting();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _updateTime();
      _updateGreeting();
    });

    // Trigger main fade-in
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = true;
      });
    });

    // Trigger button slide/fade after main content
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showButton = true;
      });
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('hh:mm a').format(now);
    setState(() {
      _currentTime = formatted;
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    setState(() {
      _greeting = greeting;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Background image
          Image.asset(
            'assets/images/comeback-background.jpg',
            fit: BoxFit.cover,
          ),

          // ✅ Overlay for contrast
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // ✅ Top-left greeting
          Positioned(
            top: 50,
            left: 25,
            child: Text(
              _greeting,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ✅ Top-right time
          Positioned(
            top: 50,
            right: 25,
            child: Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ✅ Main animated content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  const Spacer(),

                  // Logo
                  Image.asset(
                    'assets/images/comeback1-logo.png',
                    width: 100,
                    height: 100,
                  ),

                  const SizedBox(height: 30),

                  // Main quote
                  Align(
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'FOR EVERY SET BACK,\nGOD HAS A MAJOR\nCOMEBACK',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 8, 61, 236),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ✅ Animated GET STARTED button
                  AnimatedSlide(
                    offset: _showButton ? Offset.zero : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: _showButton ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: SizedBox(
                          width: 220,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'GET STARTED',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
