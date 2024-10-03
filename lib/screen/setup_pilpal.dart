import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SetupPilpal extends StatelessWidget {
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

  const SetupPilpal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setup PILPAL")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
              onTap: () => _launchURL(Uri.parse("http://192.168.4.1/"), false),
              child: Center(
                child: Container(
                    height: 50,
                    width: 350,
                    decoration:
                        BoxDecoration(color: Color.fromARGB(255, 102, 91, 251)),
                    child: Center(
                      child: Text(
                        "Open Url In External Browser",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              ))
        ],
      ),
    );
  }
}
