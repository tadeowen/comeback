import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'my_prayer_requests.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c

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
<<<<<<< HEAD
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
=======
    tz.initializeTimeZones();
    _initializeNotifications();
    fetchImams();
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal.shade700;
    final Color lightGreen = Colors.teal.shade50;

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text("🕌 Prayer Request"),
=======
        title: const Text("🍌 Prayer Request"),
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
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
<<<<<<< HEAD

                  // Imam Dropdown
=======
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
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
<<<<<<< HEAD

                  // Category Dropdown
=======
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
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
<<<<<<< HEAD

                  // Visibility Dropdown
=======
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
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
<<<<<<< HEAD

                  // Prayer Message TextField
=======
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
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
<<<<<<< HEAD

                  // Send Button
=======
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
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
<<<<<<< HEAD
=======
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MyPrayerRequestsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt, color: Colors.teal),
                      label: const Text(
                        "View Requests",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleLocalNotification(DateTime appointmentDate) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Reminders',
      channelDescription: 'Reminders for upcoming Imam appointments',
      importance: Importance.max,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      appointmentDate.hashCode,
      'Upcoming Prayer Appointment',
      'You have an appointment scheduled with the Imam.',
      tz.TZDateTime.from(
          appointmentDate.subtract(const Duration(hours: 1)), tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
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

    if (selectedImamId == null) {
      fetchCategoriesForImam(null);
    }
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

  TimeOfDay parseTime(String timeStr) {
    try {
      // Try parsing as 12-hour format first (e.g., "11:15 AM")
      final format12 = DateFormat.jm(); // h:mm a
      final dt = format12.parseStrict(timeStr);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      try {
        // If that fails, try parsing as 24-hour format (e.g., "23:30")
        final parts = timeStr.split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        throw FormatException("Invalid time format: $timeStr");
      }
    }
  }

  DateTime getNextAppointmentDate(String weekday, TimeOfDay time) {
    final now = DateTime.now();
    final weekdays = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    final targetWeekday = weekdays[weekday];
    if (targetWeekday == null) throw Exception('Invalid weekday');

    int daysUntilNext = (targetWeekday - now.weekday) % 7;
    if (daysUntilNext == 0) {
      final nowTime = TimeOfDay.fromDateTime(now);
      if (time.hour < nowTime.hour ||
          (time.hour == nowTime.hour && time.minute <= nowTime.minute)) {
        daysUntilNext = 7;
      }
    }

    final nextDate = now.add(Duration(days: daysUntilNext));
    return DateTime(
        nextDate.year, nextDate.month, nextDate.day, time.hour, time.minute);
  }

  Future<void> sendPrayerRequest() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a prayer request")),
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

    String? targetImamId = selectedImamId;
    String? confirmationDay;
    String? confirmationTime;
    DateTime? appointmentDate;

    // 1. If "Any available Imam" selected AND category is chosen
    if (targetImamId == null &&
        selectedCategory != null &&
        selectedCategory!.isNotEmpty) {
      final snapshot =
          await FirebaseFirestore.instance.collection('imamAppointments').get();

      final filteredDocs = snapshot.docs.where((doc) {
        final resp = (doc['responsibility'] as String?)?.toLowerCase().trim();
        return resp == selectedCategory!.toLowerCase().trim();
      }).toList();

      if (filteredDocs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No Imam handles this category.")),
        );
        return;
      }

      final List<Map<String, dynamic>> candidates = [];

      for (var doc in filteredDocs) {
        final data = doc.data();
        final imamId = data['imamId'];
        final day = data['day'];
        final time = data['time'];

        if (imamId == null ||
            day == null ||
            time == null ||
            day == '' ||
            time == '') {
          continue;
        }

        final ratingsSnapshot = await FirebaseFirestore.instance
            .collection('imamRatings')
            .where('imamId', isEqualTo: imamId)
            .get();

        double avgRating = 0;
        if (ratingsSnapshot.docs.isNotEmpty) {
          final total = ratingsSnapshot.docs
              .map((r) => (r['rating'] as num?)?.toDouble() ?? 0.0)
              .fold(0.0, (a, b) => a + b);

          avgRating = total / ratingsSnapshot.docs.length;
          avgRating = double.tryParse(avgRating.toStringAsFixed(1)) ?? 0.0;
        }

        print(
            "Imam $imamId handles $selectedCategory on $day at $time, rating: $avgRating");

        candidates.add({
          'imamId': imamId,
          'day': day,
          'time': time,
          'avgRating': avgRating,
        });
      }

      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No valid Imam found for the category.")),
        );
        return;
      }

      candidates.sort((a, b) => b['avgRating'].compareTo(a['avgRating']));

      final bestImam = candidates.firstWhere(
        (imam) =>
            (imam['day'] != null && imam['day'].toString().isNotEmpty) &&
            (imam['time'] != null && imam['time'].toString().isNotEmpty),
        orElse: () => {},
      );

      if (bestImam.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No Imam with a valid schedule found.")),
        );
        return;
      }

      targetImamId = bestImam['imamId'];
      confirmationDay = bestImam['day'];
      confirmationTime = bestImam['time'];

      if (confirmationDay == null || confirmationTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid appointment details.")),
        );
        return;
      }

      final timeOfDay = parseTime(confirmationTime);
      appointmentDate = getNextAppointmentDate(confirmationDay, timeOfDay);
    }

    // 2. If a specific Imam is chosen, require a category selection
    if (selectedImamId != null &&
        (selectedCategory == null || selectedCategory!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category for the Imam")),
      );
      return;
    }

    // 3. Fallback: pick a random Imam if none selected
    targetImamId ??= imams[Random().nextInt(imams.length)]['id'];

    // 4. Save appointment
    final appointmentRef =
        await FirebaseFirestore.instance.collection('appointments').add({
      'studentId': user.uid,
      'imamId': targetImamId,
      'appointmentDate':
          appointmentDate != null ? Timestamp.fromDate(appointmentDate) : null,
      'rated': false,
    });

    // 5. Save dua request
    final requestData = {
      'studentId': user.uid,
      'imamId': targetImamId,
      'message': message,
      'timestamp': Timestamp.now(),
      'visibility': visibilityOption,
      'appointmentId': appointmentRef.id,
      if (visibilityOption == 'Public') ...{
        'studentName': user.displayName ?? 'Unknown',
        'studentEmail': user.email ?? 'Not available',
      },
      if (selectedCategory != null) 'category': selectedCategory,
      if (confirmationDay != null) 'confirmationDay': confirmationDay,
      if (confirmationTime != null) 'confirmationTime': confirmationTime,
      if (appointmentDate != null)
        'appointmentDate': Timestamp.fromDate(appointmentDate),
    };

    await FirebaseFirestore.instance.collection('dua_request').add(requestData);

    // 6. Schedule notification if appointment date exists
    if (appointmentDate != null) {
      await scheduleLocalNotification(appointmentDate);
    }

    // 7. Reset form fields and reload categories
    _messageController.clear();
    setState(() {
      selectedImamId = null;
      selectedCategory = null;
      categories = [];
      imamHasNoResponsibilities = false;
      visibilityOption = 'Anonymous';
    });
    fetchCategoriesForImam(null);

    // 8. Show confirmation dialog
    final confirmationMsg = (confirmationDay != null &&
            confirmationTime != null &&
            appointmentDate != null)
        ? "Request sent! Your appointment is on ${DateFormat('yyyy-MM-dd').format(appointmentDate)} ($confirmationDay) at $confirmationTime."
        : "Prayer request sent successfully!";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(confirmationMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
}
