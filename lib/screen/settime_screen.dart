import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetTimeScreen extends StatefulWidget {
  @override
  _SetTimeScreenState createState() => _SetTimeScreenState();
}

class _SetTimeScreenState extends State<SetTimeScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? morningTime;
  TimeOfDay? afternoonTime;
  TimeOfDay? nightTime;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchNextMedicineTime();
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                if (title == 'Success') {
                  Navigator.of(context)
                      .pop(); // Navigate back to the previous screen only on success
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchNextMedicineTime() async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('times')
            .doc(user!.uid)
            .get();
        if (snapshot.exists) {
          setState(() {
            morningTime = _parseTime(snapshot['morning']);
            afternoonTime = _parseTime(snapshot['afternoon']);
            nightTime = _parseTime(snapshot['night']);
          });
          print('Fetched times: ${snapshot.data()}');
        }
      } catch (e) {
        print('Error fetching times: $e');
      }
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _selectTime(
      BuildContext context, Function(TimeOfDay) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _submitTimes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('times')
              .doc(user!.uid)
              .set({
            'morning': _formatTime(morningTime!),
            'afternoon': _formatTime(afternoonTime!),
            'night': _formatTime(nightTime!),
          }, SetOptions(merge: true));

          // Show success dialog
          _showDialog('Success', 'Times have been successfully uploaded!');
        } catch (e) {
          // Show error dialog
          _showDialog('Error', 'Failed to set times: $e');
        }
      } else {
        // Show error dialog
        _showDialog('Error', 'No user signed in');
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 65, 255, 118).withOpacity(0.7), // #CDCDD0
        centerTitle: true,
        title: Text('Set Medicine Times',
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTimeSelector(
                Icons.wb_sunny,
                'Morning',
                morningTime,
                (time) => setState(() => morningTime = time),
              ),
              SizedBox(height: 20),
              _buildTimeSelector(
                Icons.wb_cloudy,
                'Afternoon',
                afternoonTime,
                (time) => setState(() => afternoonTime = time),
              ),
              SizedBox(height: 20),
              _buildTimeSelector(
                Icons.nights_stay,
                'Night',
                nightTime,
                (time) => setState(() => nightTime = time),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTimes,
                child: Text('Save Times'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    IconData icon,
    String label,
    TimeOfDay? selectedTime,
    void Function(TimeOfDay) onPressed,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 181, 244, 160),
            Color.fromRGBO(91, 255, 54, 1)
          ], // Gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 50,
            color: Color.fromARGB(255, 47, 119, 87),
          ),
          SizedBox(width: 20), // Spacing between icon and text
          Center(
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 77, 77, 77),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  selectedTime != null ? _formatTime(selectedTime) : '00:00',
                  style: TextStyle(
                    color: Color.fromARGB(255, 150, 138, 138),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () => _selectTime(context, onPressed),
          ),
        ],
      ),
    );
  }
}
