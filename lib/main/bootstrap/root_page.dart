import 'package:engro/home_page.dart';
import 'package:engro/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  String phoneNumber = "";

  void numberExists() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = sharedPreferences.getString("PhoneNumber") ?? "";
    });
    if (phoneNumber.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  @override
  void initState() {
    numberExists();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
