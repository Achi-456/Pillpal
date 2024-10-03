import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PillPal/screen/forgotpasswordpage.dart';
import 'package:PillPal/screen/home.dart';
import 'package:PillPal/screen/signup_screen.dart';

Future<void> loadLastUsedEmail(TextEditingController emailController) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lastEmail = prefs.getString('lastEmail');
  if (lastEmail != null) {
    emailController.text = lastEmail;
  }
}

Future<void> saveLastUsedEmail(String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastEmail', email);
}

void signIn(
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
  Function(bool) setLoading,
  Function(String?) setErrorMessage,
) async {
  setLoading(true);

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    await saveLastUsedEmail(emailController.text);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    print(e.code);
    switch (e.code) {
      case 'network-request-failed':
        errorMessage = 'Please check your internet connection and try again.';
        break;
      case 'invalid-credential':
        errorMessage = 'Incorrect password. Please try again.';
        break;
      case 'invalid-email':
        errorMessage = 'No user found with this email.';
        break;
      default:
        errorMessage = 'An unexpected error occurred. Please try again.';
    }

    setErrorMessage(errorMessage);
    setLoading(false);
  }
}

void navigateToForgotPassword(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const FrogotPasswordPage()),
  );
}

void navigateToSignUp(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignUpScreen()),
  );
}
