import 'dart:convert';
import 'dart:math';

import 'package:engro/colors.dart';
import 'package:engro/constants.dart';
import 'package:engro/feature/models/notification_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notificationsList = [];
  String list = "";
  void getNotificationsList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      list = sharedPreferences.getString("notificationsList") ?? "";
      if (list.isNotEmpty) {
        notificationsList = List<Map<String, dynamic>>.from(json.decode(list));
      }
    });
    print("list $list ${notificationsList.length}");
  }

// Function to generate a random color
  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
      0.2, // Opacity (1.0 for fully opaque)
    );
  }

  @override
  void initState() {
    getNotificationsList();
    super.initState();
  }

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
        actions: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SvgPicture.asset("assets/images/bell-fill.svg"),
              ),
            ],
          ),
        ],
        title: const Text(
          "Notifications",
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
        child: notificationsList.isNotEmpty
            ? Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Requests",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 600,
                    child: SingleChildScrollView(
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: notificationsList.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: getRandomColor(),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    notificationsList[index]
                                                            ["name"]
                                                        .toString()
                                                        .substring(0, 1)
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF8B8B8B)),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    notificationsList[index]
                                                        ["name"],
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    notificationsList[index]
                                                        ["number"],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF8B8B8B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          notificationsList[index]["type"] ==
                                                  "request"
                                              ? Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _sendNotification(
                                                            notificationsList[
                                                                    index]
                                                                ["number"],
                                                            false);
                                                      },
                                                      child: SvgPicture.asset(
                                                          "assets/images/cross.svg"),
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _sendNotification(
                                                            notificationsList[
                                                                    index]
                                                                ["number"],
                                                            true);
                                                      },
                                                      child: SvgPicture.asset(
                                                          "assets/images/tick.svg"),
                                                    ),
                                                  ],
                                                )
                                              : notificationsList[index]
                                                          ["type"] ==
                                                      "accepted"
                                                  ? const Text(
                                                      "Approved",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Color(0xFF01A647),
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  : notificationsList[index]
                                                              ["type"] ==
                                                          "rejected"
                                                      ? const Text(
                                                          "Declined",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0xFFB0B0B0),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )
                                                      : notificationsList[index]
                                                                  ["type"] ==
                                                              "buzz"
                                                          ? const Text(
                                                              "Buzzed",
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Color(
                                                                      0xFF01A647),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            )
                                                          : const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                    ]),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/empty_box.png"),
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "You have no notifications yet",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<NotificationResponse> _sendNotification(
      String phoneNumber, bool status) async {
    final storage = FirebaseStorage.instance;
    try {
      // Check if the phone number exists in Firebase Storage
      Reference storageRef =
          storage.ref().child('users').child('$phoneNumber.txt');
      final userData = await storageRef.getData();

      if (userData != null) {
        final userDataString = utf8.decode(userData);
        Map<String, dynamic> mapData = jsonDecode(userDataString);
        if (mapData['deviceToken'] != null) {
          var data = await _sendFCMNotification(mapData, status);
          return data;
        } else {
          return NotificationResponse();
        }
      } else {
        return NotificationResponse();
      }
    } catch (e) {
      return NotificationResponse();
    }
  }

  Future<NotificationResponse> _sendFCMNotification(
      Map<String, dynamic> mapData, bool status) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = {
      'to': mapData['deviceToken'],
      'notification': {
        'title': sharedPreferences.getString(SPName) ?? "",
        'body': status ? 'accepted your request' : 'rejected your request',
      },
      'android': {
        'notification': {
          'notification_count': 1,
        },
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
      return NotificationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load notification response');
    }
  }
}
