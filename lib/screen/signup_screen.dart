import 'package:flutter/material.dart';

import 'package:PillPal/reuseble_widgets/password_toggle.dart';
import 'package:PillPal/reuseble_widgets/reuseble_widgets.dart';
import 'package:PillPal/screen/details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:PillPal/screen/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

Future<void> _createUserCollections(String userId) async {
  List<String> collections = [
    "slot1",
    "slot2",
    "slot3",
    "slot4",
    "times",
    "user_details",
    "reports",
    "other"
  ];

  for (String collection in collections) {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .set({"userId": userId});
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _userNameTextController.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text);
      String userId = userCredential.user!.uid;
      print("Created New Account with UID: $userId");
      await _createUserCollections(userId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => PatientDetailsForm(userId: userId)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.message}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color.fromARGB(255, 30, 151, 64).withOpacity(0.5),
                  Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Gradient overlay

          // Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logoWidget('assets/images/123.png', false),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 40,
                        color: Color.fromARGB(255, 67, 64, 64),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailTextController,
                      labelText: 'Enter Username ',
                      icon: Icons.person_outline,
                      isPassword: false, // Not a password field
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailTextController,
                      labelText: 'Enter  Email',
                      icon: Icons.person_outline,
                      isPassword: false, // Not a password field
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordTextController,
                      labelText: 'Enter Password',
                      icon: Icons.lock_outline,
                      isPassword: true, // This is a password field
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SignInSignUpButton(context, false, _signUp),
                    SizedBox(height: 20),
                    signInOption(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(color: Color.fromARGB(255, 57, 57, 57)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
          child: const Text(
            " Sign In",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
