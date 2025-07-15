import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'my_prayer_requests.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
  bool _isSending = false;

  // Color Scheme
  final Color _primaryColor = const Color(0xFF2E7D32); // Deep Islamic Green
  final Color _secondaryColor = const Color(0xFF81C784); // Light Green
  final Color _accentColor = const Color(0xFFFFD54F); // Gold Accent
  final Color _backgroundColor = const Color(0xFFF5F5F5); // Light background
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _hintColor = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    fetchImams();
    fetchCategoriesForImam(null);
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchImams() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Imam')
          .where('religion', isEqualTo: 'Islam')
          .get();

      if (mounted) {
        setState(() {
          imams = snapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc['name']})
              .toList();
        });
      }

      if (selectedImamId == null) {
        fetchCategoriesForImam(null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching imams: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> fetchCategoriesForImam(String? imamId) async {
    try {
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

      if (mounted) {
        setState(() {
          categories = fetchedCategories;
          selectedCategory = null;
          imamHasNoResponsibilities =
              (imamId != null && fetchedCategories.isEmpty);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching categories: ${e.toString()}')),
        );
      }
    }
  }

  TimeOfDay parseTime(String timeStr) {
    try {
      final format12 = DateFormat.jm();
      try {
        final dt = format12.parseStrict(timeStr);
        return TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {
        final parts = timeStr.split(":");
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
        final format12Short = DateFormat('h:mm');
        final dt = format12Short.parseStrict(timeStr);
        return TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    } catch (e) {
      throw FormatException(
          "Invalid time format: $timeStr. Expected formats: 'HH:mm', 'h:mm a', or 'h:mm'");
    }
  }

  String formatTimeForDisplay(String timeStr) {
    try {
      final timeOfDay = parseTime(timeStr);
      return DateFormat.jm()
          .format(DateTime(2023, 1, 1, timeOfDay.hour, timeOfDay.minute));
    } catch (e) {
      return timeStr;
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

  Future<void> scheduleLocalNotification(DateTime appointmentDate) async {
    try {
      const androidDetails = AndroidNotificationDetails(
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
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error scheduling notification: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> sendPrayerRequest() async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a prayer request")),
      );
      setState(() => _isSending = false);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSending = false);
      return;
    }

    if (imams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Imams available.")),
      );
      setState(() => _isSending = false);
      return;
    }

    try {
      String? targetImamId = selectedImamId;
      String? targetImamName;
      String? confirmationDay;
      String? confirmationTime;
      DateTime? appointmentDate;
      String confirmationMsg = "Prayer request sent!";

      // 1. If "Any available Imam" selected AND category is chosen
      if (targetImamId == null &&
          selectedCategory != null &&
          selectedCategory!.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('imamAppointments')
            .get();

        final filteredDocs = snapshot.docs.where((doc) {
          final resp = (doc['responsibility'] as String?)?.toLowerCase().trim();
          return resp == selectedCategory!.toLowerCase().trim();
        }).toList();

        if (filteredDocs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No Imam handles this category.")),
          );
          setState(() => _isSending = false);
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

          // Get Imam name
          final imamDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(imamId)
              .get();
          final imamName = imamDoc['name'] ?? 'Imam';

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

          candidates.add({
            'imamId': imamId,
            'imamName': imamName,
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
          setState(() => _isSending = false);
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
            const SnackBar(
                content: Text("No Imam with a valid schedule found.")),
          );
          setState(() => _isSending = false);
          return;
        }

        targetImamId = bestImam['imamId'];
        targetImamName = bestImam['imamName'];
        confirmationDay = bestImam['day'];
        confirmationTime = bestImam['time'];

        if (confirmationDay == null || confirmationTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid appointment details.")),
          );
          setState(() => _isSending = false);
          return;
        }

        final timeOfDay = parseTime(confirmationTime);
        appointmentDate = getNextAppointmentDate(confirmationDay, timeOfDay);
        confirmationMsg =
            "Request sent! Your appointment is on $confirmationDay at ${formatTimeForDisplay(confirmationTime)} with $targetImamName.";
      }

      // 2. If a specific Imam is chosen, require a category selection
      if (selectedImamId != null &&
          (selectedCategory == null || selectedCategory!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select a category for the Imam")),
        );
        setState(() => _isSending = false);
        return;
      }

      // 3. Fallback: pick a random Imam if none selected
      if (targetImamId == null) {
        final randomIndex = Random().nextInt(imams.length);
        targetImamId = imams[randomIndex]['id'];
        targetImamName = imams[randomIndex]['name'];
      }

      // 4. Get Imam name if not already set
      if (targetImamName == null) {
        final imamDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(targetImamId)
            .get();
        targetImamName = imamDoc['name'] ?? 'Imam';
      }

      // 5. Save appointment
      final appointmentRef =
          await FirebaseFirestore.instance.collection('appointments').add({
        'studentId': user.uid,
        'imamId': targetImamId,
        'appointmentDate':
            appointmentDate != null ? Timestamp.fromDate(appointmentDate) : null,
        'rated': false,
      });

      // 6. Save prayer request
      final requestData = {
        'studentId': user.uid,
        'imamId': targetImamId,
        'imamName': targetImamName,
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

      await FirebaseFirestore.instance
          .collection('dua_request')
          .add(requestData);

      if (appointmentDate != null) {
        await scheduleLocalNotification(appointmentDate);
      }

      // Reset form
      _messageController.clear();
      if (mounted) {
        setState(() {
          selectedImamId = null;
          selectedCategory = null;
          categories = [];
          imamHasNoResponsibilities = false;
          visibilityOption = 'Anonymous';
          _isSending = false;
        });
      }

      // Show success dialog
      if (mounted) {
        await _showSuccessDialog(
          message: confirmationMsg,
          appointmentDate: appointmentDate,
          confirmationDay: confirmationDay,
          confirmationTime: confirmationTime,
          imamName: targetImamName,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting request: ${e.toString()}")),
        );
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _showSuccessDialog({
    required String message,
    DateTime? appointmentDate,
    String? confirmationDay,
    String? confirmationTime,
    String? imamName,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      "Request Sent",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: _textColor,
                  ),
                ),
                if (appointmentDate != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Appointment Details:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (imamName != null)
                    _buildAppointmentDetailRow(
                      Icons.person,
                      "With $imamName",
                    ),
                  _buildAppointmentDetailRow(
                    Icons.calendar_today,
                    DateFormat('EEE, MMM d, y').format(appointmentDate),
                  ),
                  _buildAppointmentDetailRow(
                    Icons.access_time,
                    formatTimeForDisplay(confirmationTime!),
                  ),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryColor,
                    ),
                    child: const Text("DONE"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text("Prayer Request",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPrayerRequestsScreen(),
                ),
              );
            },
            tooltip: 'View Prayer History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildRequestFormCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.mosque, size: 48, color: _primaryColor),
            const SizedBox(height: 16),
            Text(
              "Seek Divine Guidance",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Submit your prayer request to our knowledgeable Imams",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestFormCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Request Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildImamDropdown(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildVisibilityDropdown(),
            const SizedBox(height: 16),
            _buildMessageField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 12),
            _buildViewRequestsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewRequestsButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyPrayerRequestsScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "View My Requests",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImamDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Imam",
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedImamId,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
            style: TextStyle(color: _textColor),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text("Any available Imam"),
              ),
              ...imams.map(
                (imam) => DropdownMenuItem(
                  value: imam['id'],
                  child: Text(
                    imam['name'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
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
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Prayer Category",
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedCategory,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
            style: TextStyle(color: _textColor),
            items: categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ))
                .toList(),
            onChanged: (imamHasNoResponsibilities || categories.isEmpty)
                ? null
                : (val) {
                    setState(() => selectedCategory = val);
                  },
            hint: Text(
              imamHasNoResponsibilities
                  ? "The chosen Imam has no responsibilities"
                  : "Select a category",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Visibility",
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            isExpanded: true,
            value: visibilityOption,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
            style: TextStyle(color: _textColor),
            items: const [
              DropdownMenuItem(
                value: 'Anonymous',
                child: Text("Anonymous"),
              ),
              DropdownMenuItem(
                value: 'Public',
                child: Text("Public (Show my name)"),
              ),
            ],
            onChanged: (value) => setState(() => visibilityOption = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Prayer Request",
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 6,
            style: TextStyle(color: _textColor),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: "Write your prayer request here...",
              hintStyle: TextStyle(color: _hintColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSending ? null : sendPrayerRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: _isSending
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Submit Request",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}