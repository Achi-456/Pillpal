import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:PillPal/screen/home.dart'; // Replace with actual home screen import
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PatientDetailsForm extends StatefulWidget {
  final String userId;

  const PatientDetailsForm({required this.userId, Key? key}) : super(key: key);

  @override
  State<PatientDetailsForm> createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _ischange = false;
  String _gender = ""; // Initialize as empty string
  Color _maleButtonColor = Colors.white; // Initial color for Male button
  Color _femaleButtonColor = Colors.white; // Initial color for Female button
  String? _imageUrl; // To store the image URL after upload

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phonenumberController.dispose();
    _countryController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPatientDetails();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source: ImageSource.camera); // or ImageSource.gallery

      if (pickedFile != null) {
        // Upload the image
        await _uploadImage(File(pickedFile.path));
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      // Create a unique filename
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Reference to Firebase Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child('uploads/$fileName');

      // Upload file
      UploadTask uploadTask = storageReference.putFile(image);

      // Wait for the upload to complete and get the download URL
      String downloadURL = await (await uploadTask).ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadURL; // Store the image URL
      });

      print('Image uploaded! Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future fetchPatientDetails() async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user_details')
            .doc(widget.userId)
            .get();
        if (snapshot.exists) {
          final details = snapshot.data() as Map<String, dynamic>;
          print("$details");
          setState(() {
            _nameController.text = details['name'] ?? '';
            _ageController.text = details['age'] ?? '';
            _phonenumberController.text = details['phonenumber'] ?? '';
            _countryController.text = details['country'] ?? '';
            _symptomsController.text = details['symptoms'] ?? '';
            _gender = details['gender'] ?? ''; // Set gender to empty string
            _imageUrl = details['imageUrl'];

            // Set the image URL if it exists
          });
          if (_gender == "Male") {
            setState(() {
              _maleButtonColor = Colors.lightGreenAccent;
              _femaleButtonColor = Colors.white;
            });
          }
          if (_gender == "Female") {
            _femaleButtonColor = Colors.lightGreenAccent;
            _maleButtonColor = Colors.white;
          }
        }
      } catch (e) {
        print('Error fetching patient details: $e');
      }
    }
  }

  Future<void> submitDetails() async {
    final String name = _nameController.text;
    final String age = _ageController.text;
    final String phonenumber = _phonenumberController.text;
    final String country = _countryController.text;
    final String symptoms = _symptomsController.text;

    if (name.isEmpty ||
        age.isEmpty ||
        phonenumber.isEmpty ||
        country.isEmpty ||
        _gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    } else {
      final userDoc = FirebaseFirestore.instance
          .collection('user_details')
          .doc(widget.userId);
      await userDoc.set({
        'name': name,
        'age': age,
        'phonenumber': phonenumber,
        'country': country,
        'symptoms': symptoms,
        'gender': _gender,
        'imageUrl': _imageUrl, // Store the image URL
      }).then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }).catchError((error) {
        print("Failed to add user: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
        centerTitle: true,
        title: Text('Patient Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_ischange) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Warning'),
                    content: Text('Do you want to discard the changes?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen())); // Navigate back to the previous screen
                        },
                        child: Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.pop(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            } // Navigate back to the previous screen
          },
        ),
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
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 350,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                          child: _buildTextField("Name", _nameController)),
                      SizedBox(height: 20),
                      _buildTextField("Age", _ageController),
                      SizedBox(height: 20),
                      _buildTextField("Phone Number", _phonenumberController),
                      SizedBox(height: 20),
                      _buildTextField("Country", _countryController),
                      SizedBox(height: 20),
                      Text('Gender',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGenderButton('Male', _maleButtonColor, () {
                            setState(() {
                              _gender = 'Male';
                              _maleButtonColor = Colors.lightGreenAccent;
                              _femaleButtonColor = Colors.white;
                            });
                          }),
                          SizedBox(width: 20),
                          _buildGenderButton('Female', _femaleButtonColor, () {
                            setState(() {
                              _gender = 'Female';
                              _femaleButtonColor = Colors.lightGreenAccent;
                              _maleButtonColor = Colors.white;
                            });
                          }),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _symptomsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.5),
                          filled: true,
                          labelText: 'Enter Symptoms (if any)',
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(
                                  255, 0, 0, 0)), // Default label color
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 106, 255, 0)),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .grey), // Border color when not focused
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal:
                                12.0, // Adjust the padding to reduce height
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 252, 0, 0)),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          // Change label color on focus
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_imageUrl !=
                          null) // Display the uploaded image if available
                        Image.network(_imageUrl!),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: Icon(Icons.add_a_photo,
                                color: Colors.black), // Replace Text with Icon
                            style: ElevatedButton.styleFrom(
                              shape:
                                  CircleBorder(), // Optional: Makes the button circular
                              padding: EdgeInsets.all(
                                  16), // Optional: Adjusts the size of the button
                              backgroundColor: const Color.fromARGB(
                                  255,
                                  168,
                                  255,
                                  70), // Optional: Set the background color
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                            onPressed: submitDetails,
                            child: Text(
                              'Submit Details',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        setState(() {
          _ischange = true;
        });
      },
      cursorColor: Color.fromARGB(255, 0, 0, 0), // Set the cursor color

      decoration: InputDecoration(
        fillColor: Colors.white.withOpacity(0.5),
        filled: true,
        labelText: 'Enter $label',
        labelStyle: TextStyle(
            color: const Color.fromARGB(255, 0, 0, 0)), // Default label color
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 106, 255, 0)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.grey), // Border color when not focused
          borderRadius: BorderRadius.circular(20.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 12.0, // Adjust the padding to reduce height
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 252, 0, 0)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        // Change label color on focus
      ),
    );
  }

  Widget _buildGenderButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      child: Text(label, style: TextStyle(color: Colors.black)),
    );
  }
}
