import 'dart:convert';

import 'package:engro/constants.dart';
import 'package:engro/feature/models/notification_model.dart';
import 'package:engro/feature/uitls/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BuzzRequest extends StatefulWidget {
  final String name;
  final String phoneNumber;
  const BuzzRequest({super.key, required this.name, required this.phoneNumber});

  @override
  State<BuzzRequest> createState() => _BuzzRequestState();
}

class _BuzzRequestState extends State<BuzzRequest> {
  bool loader = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 450,
          width: SizeUtils.width(context),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color(0xFFFDDAD7),
                  ),
                  child: const Center(
                    child: Text(
                      "A",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B8B8B)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  widget.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(
                  "+91${widget.phoneNumber}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Wants to add you to their Buzz List",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      loader = !loader;
                    });
                    _sendNotification(widget.phoneNumber, true, context);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14)),
                    shadowColor: WidgetStateProperty.all(
                        const Color.fromRGBO(255, 255, 255, 0.469)),
                    elevation: WidgetStateProperty.all(18),
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xFF4FC991),
                    ),
                  ),
                  child: const Text(
                    "Approve",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      loader = !loader;
                    });
                    _sendNotification(widget.phoneNumber, false, context);
                  },
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12)),
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    "Decline",
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        loader
            ? const Loader(
                screenHeight: 450,
              )
            : const SizedBox()
      ],
    );
  }

  List<UserData> userDataList = [];

  fetchContactsList() async {
    List<UserData> loadedUserDataList =
        await loadUserDataListFromSharedPreferences();
    if (loadedUserDataList.isNotEmpty) {
      setState(() {
        userDataList = loadedUserDataList;
      });
    } else {
      print('No UserData found in SharedPreferences.');
    }
  }

  Future<List<UserData>> loadUserDataListFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? jsonList = sharedPreferences.getStringList(contactsList);
    if (jsonList != null) {
      return jsonList
          .map((jsonString) => UserData.fromJson(jsonDecode(jsonString)))
          .toList();
    }
    return [];
  }

  Future<NotificationResponse> _sendNotification(
      String phoneNumber, bool status, context) async {
    if (status) {
      updateContactList(phoneNumber);
      updateContactListOfB(phoneNumber);
    }
    var userB = await getUserData(false, phoneNumber);
    var data = await _sendFCMNotification(userB, status, context);
    return data;
  }

  Future<NotificationResponse> _sendFCMNotification(
      UserData mapData, bool status, context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = {
      'to': mapData.deviceToken,
      'notification': {
        'title': sharedPreferences.getString(SPName) ?? "",
        'body': status ? 'accepted your request' : 'rejected your request',
        'sound': 'engro_buzz.wav'
      },
      'android': {
        'notification': {'notification_count': 1, 'sound': 'engro_buzz.wav'},
      },
      'data': {
        'type': status ? 'accepted' : "rejected",
        'id': 'flutter',
        'name': status ? (sharedPreferences.getString(SPName) ?? "") : '',
        'number': status ? (sharedPreferences.getString(SPPhone) ?? "") : '',
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
      Navigator.pop(context, "success");
      setState(() {
        loader = !loader;
      });
      return NotificationResponse.fromJson(jsonDecode(response.body));
    } else {
      setState(() {
        loader = !loader;
      });
      throw Exception('Failed to load notification response');
    }
  }

  updateContactList(String phoneNumber) async {
    final storage = FirebaseStorage.instance;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userB = await getUserData(false, phoneNumber);
    var userA = await getUserData(true, '');
    Map<String, dynamic> addUser = {
      "phoneNumber": userB.phoneNumber,
      "name": userB.name,
      "deviceToken": userB.deviceToken
    };
    userA.userContactList?.add(addUser);
    String encodeData = jsonEncode(userA.toJson());
    Reference storageRef = storage
        .ref()
        .child('users')
        .child('${sharedPreferences.getString(SPPhone)}.txt');
    await storageRef.putString(encodeData, format: PutStringFormat.raw);
  }

  updateContactListOfB(String phoneNumber) async {
    final storage = FirebaseStorage.instance;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userB = await getUserData(false, phoneNumber);
    var userA = await getUserData(true, '');
    Map<String, dynamic> addUser = {
      "phoneNumber": userA.phoneNumber,
      "name": userA.name,
      "deviceToken": userA.deviceToken
    };
    userB.userContactList?.add(addUser);
    String encodeData = jsonEncode(userB.toJson());
    Reference storageRef =
        storage.ref().child('users').child('$phoneNumber.txt');
    await storageRef.putString(encodeData, format: PutStringFormat.raw);
  }
}

Future<UserData> getUserData(bool userType, String phoneNumber) async {
  final storage = FirebaseStorage.instance;
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    Reference storageRef = storage.ref().child('users').child(userType
        ? '${sharedPreferences.getString(SPPhone)}.txt'
        : '$phoneNumber.txt');
    final userData = await storageRef.getData();
    if (userData != null) {
      final userDataAString = utf8.decode(userData);
      Map<String, dynamic> jsonData = jsonDecode(userDataAString);
      UserData mapAData = UserData.fromJson(jsonData);
      return mapAData;
    }
    return UserData();
  } catch (e) {
    return UserData();
  }
}
