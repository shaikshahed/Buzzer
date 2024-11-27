import 'dart:convert';
import 'dart:io';

import 'package:engro/buzz_request.dart';
import 'package:engro/colors.dart';
import 'package:engro/constants.dart';
import 'package:engro/feature/models/notification_model.dart';
import 'package:engro/feature/uitls/loader.dart';
import 'package:engro/feature/uitls/utils.dart';
import 'package:engro/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  const OTPScreen(
      {super.key, required this.verificationId, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  final storage = FirebaseStorage.instance;

  String otpValue = "";
  bool validateOtp = false;
  bool enableButton = false;
  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, appColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
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
                  Container(
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
                            "Verify OTP".toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          const Text(
                            "Enter OTP",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Pinput(
                                onChanged: (value) {
                                  otpValue = otpController.text;
                                  if (value.isNotEmpty && value.length == 6) {
                                    setState(() {
                                      validateOtp = true;
                                      enableButton = true;
                                    });
                                  } else {
                                    setState(() {
                                      validateOtp = false;
                                      enableButton = false;
                                    });
                                  }
                                },
                                length: 6,
                                pinAnimationType: PinAnimationType.none,
                                keyboardType: TextInputType.number,
                                controller: otpController,
                                defaultPinTheme: PinTheme(
                                  width: 44,
                                  height: 44,
                                  textStyle: const TextStyle(
                                      fontSize: 22, color: Colors.black),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 3,
                                        color: appColor,
                                      )),
                                ),
                                preFilledWidget: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Align(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading=true;
                                    });
                                    if (validateOtp) {
                                      try {
                                        PhoneAuthCredential credential =
                                            PhoneAuthProvider.credential(
                                          verificationId: widget.verificationId,
                                          smsCode: otpValue,
                                        );

                                        UserCredential userCredential =
                                            await FirebaseAuth.instance
                                                .signInWithCredential(
                                                    credential);

                                        String? deviceToken =
                                            await FirebaseMessaging.instance
                                                .getToken();
                                        SharedPreferences sharedPreferences =
                                            await SharedPreferences
                                                .getInstance();
                                        sharedPreferences.setString(
                                            'SPPhone', widget.phoneNumber);

                                        bool userSaved = await saveUserData(
                                            widget.phoneNumber, '', []);
                                        if (userSaved) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(),
                                            ),
                                          );
                                        } else {
                                          // Handle save user data failure
                                          Utils().toastMessage(
                                              'Failed to save user data.',
                                              true);
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code ==
                                            'invalid-verification-code') {
                                          Utils().toastMessage(
                                              'The OTP entered is invalid. Please try again.',
                                              false);
                                        } else {
                                          Utils().toastMessage(
                                              'Something went wrong. Please try again later.',
                                              true);
                                        }
                                      } catch (e) {
                                        Utils()
                                            .toastMessage(e.toString(), true);
                                      }
                                      // try {
                                      //   PhoneAuthCredential credential =
                                      //       await PhoneAuthProvider.credential(
                                      //           verificationId: widget.verificationId,
                                      //           smsCode: otpValue);
                                      //   FirebaseAuth.instance
                                      //       .signInWithCredential(credential)
                                      //       .then((value) async {
                                      //     String? deviceToken =
                                      //         await FirebaseMessaging.instance.getToken();
                                      //     SharedPreferences sharedPreferences =
                                      //         await SharedPreferences.getInstance();
                                      //     sharedPreferences.setString(
                                      //         SPPhone, widget.phoneNumber);
                                      //     bool value = await saveUserData(
                                      //         widget.phoneNumber, '', []);
                                      //     Navigator.of(context).push(
                                      //       MaterialPageRoute(
                                      //         builder: (context) => ProfileScreen(),
                                      //       ),
                                      //     );
                                      //   });
                                      // } catch (e) {
                                      //   print("errorddd $e");
                                      //   Utils().toastMessage("${e}", false);
                                      // }
                                    }
                                    setState(() {
                                      isLoading=false;
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                    )),
                                    padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 12)),
                                    backgroundColor: WidgetStateProperty.all(
                                      enableButton
                                          ? const Color(0xFF00B2FF)
                                          : Colors.grey.shade300,
                                    ),
                                    // side: MaterialStateProperty.all(buttonBorder)
                                  ),
                                  child: isLoading?const CircularProgressIndicator():const  Text(
                                    "Login",
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
                ]),
          ),
        ),
      ),
    ));
  }

  Future<bool> saveUserData(
      String phoneNumber, String name, List<UserData> userContactList) async {
    try {
      if (Platform.isIOS) {
        FirebaseMessaging.instance.deleteToken();
      }
      //
      String? deviceToken = await FirebaseMessaging.instance.getToken();
      Reference storageRef =
          storage.ref().child('users').child('$phoneNumber.txt');
      var checkUser = await getUserData(false, phoneNumber);
      var arrayData = (checkUser.deviceToken ?? "").isNotEmpty
          ? checkUser.userContactList
          : [];
      // Create a string with the user data
      Map<String, dynamic> userData = {
        "phoneNumber": phoneNumber,
        "name": name != "" ? name : "Unknown",
        "deviceToken": deviceToken,
        "userContactList": arrayData
      };

      print(userData);
      // Encode user data
      String encodeData = jsonEncode(userData);
      // Upload the string to Firebase Storage
      await storageRef.putString(encodeData, format: PutStringFormat.raw);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(SPPhone, phoneNumber);
      sharedPreferences.setString(SPName, name);
      return true;
    } catch (e) {
      return false;
    }
  }
}
