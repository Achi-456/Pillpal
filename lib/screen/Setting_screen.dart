import 'package:PillPal/screen/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PillPal/screen/Slot1Screen.dart';
import 'package:PillPal/screen/settime_screen.dart';
import 'package:PillPal/screen/details.dart'; // Assuming this contains PatientDetailsForm
import 'package:flutter/services.dart'; // For Clipboard

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String _name = '';
  String _age = '';
  String _phonenumber = '';
  String _country = '';
  String _symptoms = '';
  String _gender = '';
  String _imageUrl = '';
  String? userEmail;

  bool _isExpanded = false;
  bool _isSelect = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
    fetchPatientDetails();
  }

  void getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  Future<void> fetchPatientDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user_details')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          final details = snapshot.data() as Map<String, dynamic>;
          print("$details");
          setState(() {
            _name = details['name'] ?? '';
            _age = details['age'] ?? '';
            _phonenumber = details['phonenumber'] ?? '';
            _country = details['country'] ?? '';
            _symptoms = details['symptoms'] ?? '';
            _gender = details['gender'] ?? '';
            _imageUrl = details['imageUrl'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching patient details: $e');
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Settings",
            style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 76, 255, 127).withOpacity(0.9),
                Color.fromARGB(255, 138, 255, 171).withOpacity(0.5)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 76, 255, 127).withOpacity(0.9),
                    Color.fromARGB(255, 138, 255, 171).withOpacity(0.5)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 101, 154, 87),
                        radius: 40,
                        backgroundImage: _imageUrl.isNotEmpty
                            ? NetworkImage(_imageUrl)
                            : null,
                        child: _imageUrl.isEmpty
                            ? Icon(Icons.person, size: 40, color: Colors.black)
                            : null,
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name.isNotEmpty ? _name : "User Name",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userEmail ?? "User Email",
                            style: TextStyle(
                              color: Color.fromARGB(255, 100, 100, 100),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        _isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  if (_isExpanded) ...[
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _copyToClipboard(_age),
                      child: Text(
                        "Age: $_age",
                        style:
                            TextStyle(color: Color.fromARGB(255, 71, 72, 91)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _copyToClipboard(_phonenumber),
                      child: Text(
                        "Phone: $_phonenumber",
                        style:
                            TextStyle(color: Color.fromARGB(255, 71, 72, 91)),
                      ),
                    ),
                    Text(
                      "Country: $_country",
                      style: TextStyle(color: Color.fromARGB(255, 71, 72, 91)),
                    ),
                    Text(
                      "Symptoms: $_symptoms",
                      style: TextStyle(color: Color.fromARGB(255, 71, 72, 91)),
                    ),
                    Text(
                      "Gender: $_gender",
                      style: TextStyle(color: Color.fromARGB(255, 71, 72, 91)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blueGrey),
                  title: Text("Time Settings"),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SetTimeScreen()),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _isSelect ? Color(0xFFf0f0f0) : Colors.transparent,
                  ),
                  child: ListTile(
                    selectedColor: Color(0xFF73ba9b),
                    leading:
                        FaIcon(FontAwesomeIcons.pills, color: Colors.blueGrey),
                    title: Text("Change Slot details"),
                    trailing: Icon(
                      _isSelect
                          ? Icons.arrow_drop_down
                          : Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        _isSelect = !_isSelect;
                      });
                    },
                  ),
                ),
                if (_isSelect) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 8),
                    child: Container(
                      height: 160,
                      child: ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 40,
                            child: ListTile(
                              title: Text("Slot ${index + 1}"),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.grey, size: 15),
                              titleAlignment: ListTileTitleAlignment.center,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SlotScreen(index + 1)),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.fileMedical,
                      color: Colors.blueGrey),
                  title: Text("Edit Patient Details"),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PatientDetailsForm(
                              userId: FirebaseAuth.instance.currentUser!.uid)),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.blueGrey),
                  title: Text("Log out"),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () async {
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
