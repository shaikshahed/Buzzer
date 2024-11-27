import 'dart:convert';

import 'package:engro/colors.dart';
import 'package:engro/constants.dart';
import 'package:engro/feature/models/notification_model.dart';
import 'package:engro/feature/uitls/loader.dart';
import 'package:engro/feature/uitls/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  final storage = FirebaseStorage.instance;
  String nameValue = "";
  String numberValue = "";
  bool loader = false;
  bool isLoading = false;
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: const Color.fromRGBO(255, 255, 255, 0.469),
        elevation: 18,
        surfaceTintColor: Colors.white,
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
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
        title: const Text(
          "Add",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formkey,
        child: Container(
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
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Name",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              autofocus: true,
                              onChanged: (value) {
                                setState(() {
                                  nameValue = nameController.text;
                                });
                              },
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                hintText: "Enter Name",
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
                                        color: Colors.black, width: 1)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1)),
                                fillColor: const Color(0xFFFAFAFA),
                              ),
                              validator: (value) {
                                if(value== null || value.isEmpty){
                                  return "Please Enter Name";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              controller: nameController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Text(
                              "Phone Number",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              autofocus: true,
                              onChanged: (value) {
                                setState(() {
                                  numberValue = numberController.text;
                                });
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
                                        color: Colors.black, width: 1)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1)),
                                fillColor: const Color(0xFFFAFAFA),
                              ),
                              validator: (value) {
                                if(value== null || value.isEmpty){
                                  return "Please Enter Number";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              controller: numberController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Center(
                              child: SizedBox(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // setState(() {
                                    //   loader = !loader;
                                    // });
                                    if(_formkey.currentState!.validate()){
                                       setState(() {
                                      isLoading=true;
                                    });
                                    FocusScope.of(context).unfocus();
                                    var response =
                                        await _sendNotification(numberValue);
                                        setState(() {
                                          isLoading=false;
                                        });
                                    if (response.success == 1) {
                                      // setState(() {
                                      //   loader = !loader;
                                      // });
                                      setState(() {
                                        isLoading=false;
                                      });
                                      Navigator.pop(context);
                                    } else {
                                      // setState(() {
                                      //   loader = !loader;
                                      // });
                                      // setState(() {
                                      //   isLoading=true;
                                      // });
                                    }
                                    }
                                  },
                      
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0)
                                      )
                                    ),
                                    padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 12)),
                                    backgroundColor: WidgetStateProperty.all(
                                      const Color(0xFF00B2FF),
                                    ),
                                  ),
                                  child: isLoading?const CircularProgressIndicator(): const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add ",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
            loader ? const Loader() : const SizedBox()
          ]),
        ),
      ),
    );
  }

  Future<NotificationResponse> _sendNotification(String phoneNumber) async {
    try {
      // Check if the phone number exists in Firebase Storage
      Reference storageRef =
          storage.ref().child('users').child('$phoneNumber.txt');
      final userData = await storageRef.getData();

      if (userData != null) {
        final userDataString = utf8.decode(userData);
        Map<String, dynamic> mapData = jsonDecode(userDataString);
        if (mapData['deviceToken'] != null) {
          var data = await _sendFCMNotification(mapData);
          return data;
        } else {
          Utils().toastMessage('Something wrong!', false);
          return NotificationResponse();
        }
      } else {
        Utils().toastMessage('User not found!', false);
        return NotificationResponse();
      }
    } catch (e) {
      Utils().toastMessage('Something wrong!', false);
      return NotificationResponse();
    }
  }

  Future<NotificationResponse> _sendFCMNotification(
      Map<String, dynamic> mapData) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = {
      'to': mapData['deviceToken'],
      'notification': {
        'title': sharedPreferences.getString(SPName) ?? "",
        'body': 'Want to add you in Buzz',
        'sound': 'engro_buzz.wav'
      },
      'android': {
        'notification': {'notification_count': 1, 'sound': 'engro_buzz.wav'},
      },
      'data': {
        'type': 'request',
        'name': sharedPreferences.getString(SPName) ?? "",
        'number': sharedPreferences.getString(SPPhone) ?? "",
      }
    };

    final response = await http.post(
      Uri.parse(fcmPath),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': serverKey,
      },
    );

    if (response.statusCode == 200) {
      Utils().toastMessage('Successfully sent a request!', true);
      return NotificationResponse.fromJson(jsonDecode(response.body));
    } else {
      Utils().toastMessage('Failed to send a request!', false);
      throw Exception('Failed to load notification response');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }
}
