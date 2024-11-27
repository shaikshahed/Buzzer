import 'dart:convert';
import 'dart:io';

import 'package:engro/buzz_request.dart';
import 'package:engro/colors.dart';
import 'package:engro/constants.dart';
import 'package:engro/feature/models/notification_model.dart';
import 'package:engro/feature/uitls/loader.dart';
import 'package:engro/feature/uitls/utils.dart';
import 'package:engro/home_page.dart';
import 'package:engro/login_page.dart';
import 'package:engro/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FirebaseStorage.instance;
  String phoneNumber = "";
  TextEditingController numberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String numberValue = "";
  bool validateNumber = true;
  bool loader = false;
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  void getNumber() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = sharedPreferences.getString(SPPhone) ?? "";
      nameController.text = sharedPreferences.getString(SPName) ?? "";
      numberController.text = phoneNumber;
    });
  }

  @override
  void initState() {
    getNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: const Color.fromRGBO(255, 255, 255, 0.469),
        elevation: 18,
        surfaceTintColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () async {
              _signOut();
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              sharedPreferences.clear();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyApp(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                "Logout",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF323232),
                  size: 25,
                ),
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
                },
              ),
            );
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appColor,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Name:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Form(
                    key: _formkey,
                    child: TextFormField(
                      onChanged: (value) {},
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "Enter full name",
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
                                color: Colors.black, width: 1),),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.5)),
                        fillColor: const Color(0xFFFAFAFA),
                      ),
                      validator: (value) {
                        if(value ==  null || value.isEmpty){
                          return "Please Enter Name";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      controller: nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  const Text(
                    "Phone Number:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      onChanged: (value) {
                        numberValue = numberController.text;
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
                      keyboardType: TextInputType.number,
                      controller: numberController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      validateNumber ? "" : "Invalid phone number",
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if(_formkey.currentState!.validate()){
                          //   setState(() {
                          //   loader = !loader;
                          // });
                          setState(() {
                            isLoading = true;
                          });
                          FocusScope.of(context).unfocus();
                          bool value = await saveUserData(
                              numberController.text, nameController.text, []);
                          if (value) {
                            // setState(() {
                            //   loader = !loader;
                            // });
                            setState(() {
                              isLoading = true;
                            });
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                            Utils().toastMessage(
                                "Successfully updated the details", true);
                              setState(() {
                                isLoading = false;
                              });
                          } else {
                            // setState(() {
                            //   loader = !loader;
                            // });
                            setState(() {
                              isLoading= false;
                            });
                            Utils().toastMessage("Something went wrong", false);
                          }
                          }
                        },
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )
                          ),
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12)),
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF00B2FF),
                          ),
                          // side: MaterialStateProperty.all(buttonBorder)
                        ),
                        child: isLoading?CircularProgressIndicator(): const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loader ? const Loader() : const SizedBox()
          ],
        ),
      ),
    );
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
