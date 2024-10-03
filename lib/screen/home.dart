import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:PillPal/screen/Setting_screen.dart';
import 'package:PillPal/screen/Slot1Screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:PillPal/screen/records_screen.dart';
import 'package:PillPal/screen/settime_screen.dart';
import 'package:PillPal/screen/signin_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  DateTime? nextMedicineTime;
  String selectedSlot = "slot1";
  int selectedSlotIndex = 1;
  String? medicineName;
  int? pillsRemaining;
  bool ismorning = false;
  bool isafternoon = false;
  bool isnight = false;
  int? tabletCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchNextMedicineTime();
    fetchExistingData(selectedSlot);
  }

  Future<void> fetchNextMedicineTime() async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('times')
            .doc(user!.uid)
            .get();
        if (snapshot.exists) {
          print(snapshot.data());
          final morningTime = _parseTime(snapshot['morning']);
          final afternoonTime = _parseTime(snapshot['afternoon']);
          final nightTime = _parseTime(snapshot['night']);

          if (morningTime == null ||
              afternoonTime == null ||
              nightTime == null) {
            throw Exception(
                'One or more times are null or incorrectly formatted.');
          }

          final now = DateTime.now();

          DateTime morningDateTime = DateTime(now.year, now.month, now.day,
              morningTime.hour, morningTime.minute);
          DateTime afternoonDateTime = DateTime(now.year, now.month, now.day,
              afternoonTime.hour, afternoonTime.minute);
          DateTime nightDateTime = DateTime(
              now.year, now.month, now.day, nightTime.hour, nightTime.minute);

          List<DateTime> medicineTimes = [
            morningDateTime,
            afternoonDateTime,
            nightDateTime
          ];

          DateTime nextTime = medicineTimes.firstWhere(
              (time) => time.isAfter(now),
              orElse: () => medicineTimes.first.add(Duration(days: 1)));

          setState(() {
            nextMedicineTime = nextTime;
          });
          print('Next medicine time set: $nextMedicineTime');
        }
      } catch (e) {
        setState(() {
          nextMedicineTime = null;
        });
        print('Error fetching time: $e');
      }
    }
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null) return null;
    try {
      final format = DateFormat.Hm(); // '18:00' for 6:00 PM in 24-hour format
      return TimeOfDay.fromDateTime(format.parse(time));
    } catch (e) {
      print('Error parsing time: $time, Error: $e');
      return null;
    }
  }

  void fetchExistingData(String slot) async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection(slot)
            .doc(user!.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot;
          setState(() {
            pillsRemaining = data["pill_count"];
            medicineName = data['medicine_name'];
            ismorning = data['morning_dose'];
            isafternoon = data['afternoon_dose'];
            isnight = data['night_dose'];
            tabletCount = data['tablet_count'];
            print(
                "morning dose is $ismorning , afternoon dose is $isafternoon , night dose is $isnight");
          });
          print('Fetched data from $slot: $data');
        } else {
          print('No data found in $slot');
          setState(() {
            pillsRemaining = 0;
            medicineName = 'None';
            ismorning = false;
            isafternoon = false;
            isnight = false;
            tabletCount = 0;
            print(
                "morning dose is $ismorning , afternoon dose is $isafternoon , night dose is $isnight");
          });
        }
      } catch (e) {
        setState(() {
          pillsRemaining = 0;
          medicineName = 'None';
          ismorning = false;
          isafternoon = false;
          isnight = false;
          tabletCount = 0;
          print(
              "morning dose is $ismorning , afternoon dose is $isafternoon , night dose is $isnight");
        });
        print('Error fetching data from $slot: $e');
      }
    }
  }

  void _launchURL(Uri uri, bool inAPP) async {
    try {
      if (await canLaunchUrl(uri)) {
        if (inAPP) {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        } else {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi), // Flip the icon horizontally
            child: Icon(
              Icons.logout,
              color: Colors.black,
            ),
          ),
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (Route<dynamic> route) => false,
              );
            } catch (error) {
              print("Failed to sign out: $error");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to sign out: $error")),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              )
            },
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          fetchExistingData(selectedSlot);
          fetchNextMedicineTime();
        },
        child: Container(
          // Applying the gradient background
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color.fromARGB(255, 30, 151, 64).withOpacity(0.5),
                Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
                // Lighter green at the top
                // Darker green at the bottom
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  child: Card(
                    color: Color(0xFF393E46),
                    child: ListTile(
                      title: Center(
                          child: Text(
                        'Next Medicine',
                        style: TextStyle(color: Colors.white),
                      )),
                      subtitle: Center(
                        child: nextMedicineTime != null
                            ? Column(
                                children: [
                                  Text(
                                    ' ${DateFormat.jm().format(nextMedicineTime!)}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    formatTimeRemaining(nextMedicineTime!),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SetTimeScreen()),
                                  ).then((value) => fetchNextMedicineTime());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  'Set Time',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.5)),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Remaining Medicine',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222831)),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ]),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buildSlotButton('slot1'),
                                    SizedBox(width: 15),
                                    buildSlotButton('slot2'),
                                    SizedBox(width: 15),
                                    buildSlotButton('slot3'),
                                    SizedBox(width: 15),
                                    buildSlotButton('slot4'),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Medicine - $medicineName ",
                                  style: TextStyle(
                                      fontSize: 20, color: Color(0xFF222831)),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Pill Count - $pillsRemaining ",
                                  style: TextStyle(
                                      fontSize: 20, color: Color(0xFF222831)),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 20),
                                    _buildIcon(
                                        Icons.wb_sunny, 'Morning', ismorning),
                                    SizedBox(width: 30),
                                    _buildIcon(Icons.brightness_5, 'Afternoon',
                                        isafternoon),
                                    SizedBox(width: 30),
                                    _buildIcon(
                                        Icons.nights_stay, 'Night', isnight),
                                    SizedBox(width: 30),
                                  ],
                                ),
                                if (medicineName == "None" &&
                                    pillsRemaining == 0)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SlotScreen(
                                                  getSlotIndex(selectedSlot))));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 135, 255, 92),
                                    ),
                                    child: Text("Add Medicines details",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Setup PILLPALL'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Connect to PILLPALL:',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(
                                            height:
                                                8), // Optional: Adds some space between the texts
                                        Text(
                                          'SSID: Pillpal',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[
                                                700], // Optional: Customize the text color
                                          ),
                                        ),
                                        Text(
                                          'Password: 12345678',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[
                                                700], // Optional: Customize the text color
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "OR",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "Scan the QR code in the back",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700]),
                                        )
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _launchURL(
                                              Uri.parse("http://192.168.4.1/"),
                                              false);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 189, 255, 90),
                              fixedSize: Size(100, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20), // Adjust vertical padding
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.settings_remote,
                                    color: Colors.black),
                                SizedBox(height: 10),
                                Text(
                                  'Setup PILLPALL',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16), // Adjust font size
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReportsScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 189, 255, 90),
                              fixedSize: Size(100, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20), // Adjust vertical padding
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, color: Colors.black),
                                SizedBox(height: 10),
                                Text(
                                  'Previous Records',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16), // Adjust font size
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSlotButton(String slot) {
    bool isSelected = selectedSlot == slot;

    // Define a map to handle slot labels
    final Map<String, String> slotLabels = {
      "slot1": "Slot 1",
      "slot2": "Slot 2",
      "slot3": "Slot 3",
      "slot4": "Slot 4",
    };

    // Get the label for the current slot
    final String label = slotLabels[slot] ?? "";

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSlot = slot;
        });

        fetchExistingData(slot);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Color.fromARGB(245, 0, 255, 21)
                  : Color.fromARGB(255, 61, 61, 61),
              width: 2.0, // Thickness of the border
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Center(
          child: Text(
            "    $label    ",
            style: TextStyle(
              color: Color(0xFF222831),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildActionButton(String title) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        minimumSize: Size(double.infinity, 60),
      ),
    );
  }

  int getSlotIndex(String slot) {
    switch (slot) {
      case 'slot1':
        return 1;
      case 'slot2':
        return 2;
      case 'slot3':
        return 3;
      case 'slot4':
        return 4;
      default:
        return 1;
    }
  }

  String formatTimeRemaining(DateTime nextTime) {
    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours remaining';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes remaining';
    } else {
      return 'Less than a minute remaining';
    }
  }

  Widget _buildIcon(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Icon(icon,
            size: 36,
            color:
                isSelected ? Colors.black : Color.fromARGB(255, 137, 137, 137)),
        SizedBox(height: 4),
        Column(
          children: [
            Text(
              label,
              style: TextStyle(
                  color: isSelected
                      ? Colors.black
                      : Color.fromARGB(255, 137, 137, 137)),
            ),
            if (isSelected)
              Text(
                "$tabletCount ",
                style: TextStyle(
                    color: isSelected
                        ? Colors.black
                        : Color.fromARGB(255, 137, 137, 137)),
              )
            else
              Text(
                "0",
                style: TextStyle(
                    color: isSelected
                        ? Colors.black
                        : Color.fromARGB(255, 137, 137, 137),
                    fontSize: 20),
              ),
          ],
        ),
      ],
    );
  }
}
