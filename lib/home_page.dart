import 'dart:convert';

import 'package:engro/add_contact.dart';
import 'package:engro/buzz_notification.dart';
import 'package:engro/buzz_request.dart';
import 'package:engro/colors.dart';
import 'package:engro/constants.dart';
import 'package:engro/feature/models/notification_model.dart';
import 'package:engro/feature/uitls/loader.dart';
import 'package:engro/feature/uitls/utils.dart';
import 'package:engro/home_widget.dart';
import 'package:engro/main.dart';
import 'package:engro/notifications_page.dart';
import 'package:engro/profile_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_widget/home_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = FirebaseStorage.instance;
  Map<String, dynamic> myMap = {};
  bool loader = false;

  @override
  void initState() {
    HomeWidget.widgetClicked.listen((Uri? uri) => loadData());
    loadData(); // This will load data from widget every time app is opened
    fetchContactsList();
    // notification(_setMessageData);
    // notificationBackground(_setMessageData);

    super.initState();
  }

  // Callback function to set message data
  void _setMessageData(Map<String, dynamic> data) {
    setState(() {
      myMap = data;
    });
    if (data['type'] == 'request') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBottomSheet();
      });
    } else if (data['type'] == 'buzz') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBottomSheetBuzz();
      });
    }
    if (data['type'] == 'response') {
      // _response(data);
      print("responseeeeeeeeeee->$data");
    }
    print('myMapmyMap->${data['type']}');
  }

  String contactsString = '';

  List<Map<String, dynamic>> contacts = [];
  fetchContactsList() async {
    var user = await getUserData(true, '');
    if (user.userContactList != null) {
      setState(() {
        contacts = user.userContactList ?? [];
        contactsString = jsonEncode(contacts);
      });
    }
  }

  //For Homescreen widgets

  void loadData() async {
    await HomeWidget.getWidgetData<String>('_contactList', defaultValue: '')
        .then((value) {
      contactsString = value!;
    });
    setState(() {});
  }

  Future<void> updateAppWidget() async {
    await HomeWidget.saveWidgetData<String>('_contactList', contactsString);
    await HomeWidget.updateWidget(
        name: 'HomeScreenWidgetProvider', iOSName: 'HomeScreenWidgetProvider');
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
              child: SvgPicture.asset("assets/images/bellLogo.svg"),
            );
          },
        ),
        actions: <Widget>[
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.widgets,
                  color: Color(0xFF323232),
                ),
                onPressed: () {
                  updateAppWidget();
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => HomeWidgetPage(
                  //       title: 'Home Widgets',
                  //     ),
                  //   ),
                  // );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Color(0xFF323232),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(),
                      ),
                    );
                  },
                  child: SvgPicture.asset("assets/images/bell.svg")),
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF323232),
                ),
                onPressed: () {
                  fetchContactsList();
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: FloatingActionButton(
          onPressed: () async {
            SharedPreferences shared = await SharedPreferences.getInstance();
            if ((shared.getString(SPPhone) ?? "").isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddContact(),
                ),
              );
            } else {
              Utils().toastMessage("Please login", true);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            }
          },
          backgroundColor: const Color(0xFF00B2FF),
          shape: const CircleBorder(eccentricity: 0),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Container(
        height: SizeUtils.height(context),
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
        child: Stack(
          children: [
            contacts.isEmpty
                ? Center(
                    child: GestureDetector(
                      onTap: () {
                        fetchContactsList();
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/empty_box.png"),
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "You have no contacts yet. \nTap to refresh",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFF323232),
                              ),
                              onPressed: () {
                                fetchContactsList();
                              },
                            ),
                          ]),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                loader = !loader;
                              });
                              _sendNotification(
                                  contacts[index]['phoneNumber'], context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors
                                        .blue, // Change the background color as needed
                                    radius: 20,
                                    child: Text(
                                      (contacts[index]['name'] ?? "").isNotEmpty
                                          ? (contacts[index]['name'] ?? "")[0]
                                              .toUpperCase()
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Add space between CircleAvatar and Text widgets
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contacts[index]['name'] ?? "",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          contacts[index]['phoneNumber'] ?? "",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "assets/images/bellLogo.svg",
                                    width: 30,
                                  ), // Changed Icon to add_alert for notification
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
            Expanded(child: loader ? const Loader() : const SizedBox()),
          ],
        ),
      ),
    );
  }

  void showBottomSheet() async {
    final result = await showMaterialModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BuzzRequest(
        name: myMap["name"],
        phoneNumber: myMap["number"],
      ),
    );
    if (result != null) {
      setState(() {
        fetchContactsList();
      });
    }
  }

  void showBottomSheetBuzz() async {
    final result = await showMaterialModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BuzzNotification(
        name: myMap["name"],
        phoneNumber: myMap["number"],
      ),
    );
    if (result != null) {
      setState(() {
        fetchContactsList();
      });
    }
  }

  Future<NotificationResponse> _sendNotification(
      String phoneNumber, context) async {
    print(' $phoneNumber');
    var userB = await getUserData(false, phoneNumber);
    var data = await _sendFCMNotification(userB, context);
    return data;
  }

  Future<NotificationResponse> _sendFCMNotification(
      UserData mapData, context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = {
      'to': mapData.deviceToken,
      'notification': {
        'title': sharedPreferences.getString(SPName) ?? "",
        'body': 'is calling you',
        'sound': 'engro_buzz.wav'
      },
      'android': {
        'notification': {'notification_count': 1, 'sound': 'engro_buzz.wav'},
      },
      'data': {
        'type': 'buzz',
        'id': 'flutter',
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
}
