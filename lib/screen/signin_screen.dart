import 'package:flutter/material.dart';
import 'package:PillPal/reuseble_widgets/password_toggle.dart';
import 'package:PillPal/reuseble_widgets/reuseble_widgets.dart';
import 'package:PillPal/auth/auth_functions.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadLastUsedEmail(_emailTextController);
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void setErrorMessage(String? message) {
    setState(() {
      _errorMessage = message;
    });
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromARGB(255, 30, 151, 64).withOpacity(0.5),
                  Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logoWidget('assets/images/123.png', true),
                    // Gradient overlay
                    SizedBox(height: 40),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 40,
                        color: Color.fromARGB(255, 67, 64, 64),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailTextController,
                      labelText: 'Enter Username or Email',
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

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => navigateToForgotPassword(context),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFF1e2019),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SignInSignUpButton(
                            context,
                            true,
                            () => signIn(
                                  context,
                                  _emailTextController,
                                  _passwordTextController,
                                  setLoading,
                                  setErrorMessage,
                                )),
                    SizedBox(height: 20),
                    signUpOption(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Color.fromARGB(255, 70, 68, 68)),
        ),
        GestureDetector(
          onTap: () => navigateToSignUp(context),
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
