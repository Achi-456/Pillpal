import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  bool lastfivedays = true;

  // Function to generate a list of the last five days in 'yyyy-MM-dd' format
  List<String> getLastFiveDays(bool lastfivedays) {
    List<String> dates = [];
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    if (lastfivedays) {
      for (int i = 0; i < 5; i++) {
        DateTime date = now.subtract(Duration(days: i));
        dates.add(formatter.format(date));
      }
    } else {
      for (int i = 0; i < 10; i++) {
        DateTime date = now.subtract(Duration(days: i));
        dates.add(formatter.format(date));
      }
    }

    return dates;
  }

  Future<Map<String, Map<String, dynamic>>> getReports(
      bool lastfivedays) async {
    Map<String, Map<String, dynamic>> reportsData = {};
    List<String> lastFiveDays = getLastFiveDays(lastfivedays);

    for (String date in lastFiveDays) {
      try {
        // Reference to the date collection
        CollectionReference dateCollection =
            _firestore.collection('reports').doc(user!.uid).collection(date);

        // Attempt to fetch any document from the collection
        QuerySnapshot snapshot = await dateCollection.limit(1).get();

        // Check if the collection contains any documents
        if (snapshot.docs.isNotEmpty) {
          // Collection exists, fetch specific documents
          DocumentSnapshot morningDoc =
              await dateCollection.doc('Morning').get();
          DocumentSnapshot afternoonDoc =
              await dateCollection.doc('Afternoon').get();
          DocumentSnapshot nightDoc = await dateCollection.doc('Night').get();

          // Create a map for the current date
          Map<String, dynamic> dayParts = {
            'Morning': morningDoc.exists ? morningDoc.data() : {'taken': false},
            'Afternoon':
                afternoonDoc.exists ? afternoonDoc.data() : {'taken': false},
            'Night': nightDoc.exists ? nightDoc.data() : {'taken': false},
          };

          reportsData[date] = dayParts;
          print("Data for $date: $dayParts");
        } else {
          // Collection does not exist, assume all parts are false
          reportsData[date] = {
            'Morning': {'taken': false},
            'Afternoon': {'taken': false},
            'Night': {'taken': false},
          };
        }
      } catch (e) {
        // Log error and continue processing other dates
        print("Error checking or fetching data for date $date: $e");
        reportsData[date] = {
          'Morning': {'taken': false},
          'Afternoon': {'taken': false},
          'Night': {'taken': false},
        };
      }
    }
    return reportsData;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  lastfivedays = !lastfivedays;
                });
                setState(() {});
              },
              icon: Icon(
                Icons.more_horiz,
                color: Colors.black,
              ))
        ],
        title: Text("Reports",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
              Color.fromARGB(255, 138, 255, 171).withOpacity(0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Container(
              width: 350,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(25)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: getReports(lastfivedays),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No reports found'));
                    }

                    return Container(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          String date = snapshot.data!.keys.elementAt(index);
                          Map<String, dynamic> dayParts = snapshot.data![date]!;

                          return Card(
                            color: Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.7),
                            margin: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(date,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      buildDayPartButton(context, 'Morning',
                                          dayParts['Morning']),
                                      SizedBox(width: 16.0),
                                      buildDayPartButton(context, 'Afternoon',
                                          dayParts['Afternoon']),
                                      SizedBox(width: 16.0),
                                      buildDayPartButton(
                                          context, 'Night', dayParts['Night']),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDayPartButton(
      BuildContext context, String label, Map<String, dynamic> data) {
    bool status = data['taken'] ?? false;

    // Format the time in AM/PM format
    String formattedTime = '';
    if (data.containsKey('time')) {
      DateTime dateTime = (data['time'] as Timestamp).toDate();

      // Subtract 5.5 hours (5 hours and 30 minutes)
      dateTime = dateTime.subtract(Duration(hours: 5, minutes: 30));

      // Format the adjusted time in AM/PM format
      formattedTime = DateFormat('hh:mm a').format(dateTime);
    }

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: status ? Colors.green : Colors.red,
          padding: EdgeInsets.all(8.0),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("$label Details"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Taken: ${status ? "Yes" : "No"}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
// Display other details like Paracetamol, Amoxilin, etc.
                    for (var entry in data.entries)
                      if (entry.key != 'taken' && entry.key != 'time')
                        Text(
                          '${entry.key}: ${entry.value}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                    if (formattedTime.isNotEmpty)
                      Text(
                        "Time: $formattedTime",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
