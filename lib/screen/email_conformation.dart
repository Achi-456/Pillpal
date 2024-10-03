import 'package:flutter/material.dart';

class EmailConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Check your mail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "We have sent a password recover instructions to your email.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // You can implement navigation to the mail app or some other functionality
              },
              child: Text("Open email app"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Skip, I'll confirm later"),
            ),
          ],
        ),
      ),
    );
  }
}
