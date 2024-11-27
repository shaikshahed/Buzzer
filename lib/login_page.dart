import 'package:engro/colors.dart';
import 'package:engro/feature/uitls/loader.dart';
import 'package:engro/feature/uitls/utils.dart';
import 'package:engro/home_page.dart';
import 'package:engro/notifications_services.dart';
import 'package:engro/otp_screen.dart';
import 'package:flutter/material.dart';
// import 'package:otp_pin_field/otp_pin_field.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController numberContoller = TextEditingController();
  String numberValue = "";

  bool validateNumber = true;
  bool isLoading = false;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    super.initState();
  }

  @override
  void dispose() {
    numberContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, appColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/bellLogo.png",
                      scale: 3,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                // const SizedBox(
                //   height: 60.0,
                // ),
                Container(
                  // height: SizeUtils.height(context) / 3,
                  width: SizeUtils.width(context),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        new BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 20.0,
                            offset: Offset(2, 4),
                            spreadRadius: 2),
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back,".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        const Text(
                          "Phone Number",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        SizedBox(
                          height: 50,
                          child: TextFormField(
                            autofocus: true,
                            onChanged: (value) {
                              numberValue = numberContoller.text;
                              if (value.isNotEmpty &&
                                  value.length > 9 &&
                                  value.length < 11) {
                                setState(() {
                                  validateNumber = true;
                                });
                              } else {
                                setState(() {
                                  validateNumber = false;
                                });
                              }
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: "Enter phone number",
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9E9E9E),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1)),
                              fillColor: const Color(0xFFFAFAFA),
                            ),
                            keyboardType: TextInputType.phone,
                            controller: numberContoller,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                          child: Text(
                            validateNumber ? "" : "Invalid phone number",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.red),
                          ),
                        ),
                        Align(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: SizedBox(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    isLoading=true;
                                  });
                                  if (validateNumber &&
                                      numberValue.isNotEmpty) {
                                    FirebaseAuth auth = FirebaseAuth.instance;

                                    await auth.verifyPhoneNumber(
                                      phoneNumber: '+91$numberValue',
                                      verificationCompleted:
                                          (PhoneAuthCredential credential) {},
                                      verificationFailed:
                                          (FirebaseAuthException e) {
                                        if (e.code == 'invalid-phone-number') {
                                          print(
                                              'The provided phone number is not valid.');
                                        }
                                        print(
                                            'The provided phone number is not valid.${e.message}');
                                        Utils().toastMessage(
                                            "${e.message}", false);
                                      },
                                      codeAutoRetrievalTimeout:
                                          (String verificationId) {},
                                      codeSent: (String verificationId,
                                          int? resendToken) async {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => OTPScreen(
                                              verificationId: verificationId,
                                              phoneNumber: numberValue,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    print("object");
                                    setState(() {
                                      isLoading=false;
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                                  padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 14)),
                                  backgroundColor: WidgetStateProperty.all(
                                    const Color(0xFF00B2FF),
                                  ),
                                  // side: MaterialStateProperty.all(buttonBorder)
                                ),
                                child: isLoading?const CircularProgressIndicator():const  Text(
                                  "Send OTP",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => const HomePage()));
                //   },
                //   child: Container(
                //     height: 40,
                //     child: const Center(
                //       child: Text(
                //         'Skip Login',
                //         style: TextStyle(
                //             color: Colors.black,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w600),
                //       ),
                //     ),
                //   ),
                // )
              ]),
        ),
      ),
    ));
  }
}
