import 'dart:convert';

import 'package:engro/buzz_request.dart';
import 'package:engro/home_page.dart';
import 'package:engro/login_page.dart';
import 'package:engro/main/bootstrap/root_page.dart';
import 'package:engro/notifications_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'main/bootstrap/bootstrap.dart';

void main() {
  bootstrap(
    (
      sharedPreferences,
    ) async {
      return MyApp();
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var uid;
  void inputData() {
    final User? user = auth.currentUser;
    uid = user?.uid;
    print("uid  $uid");
    // here you write the codes to input the data into firestore
  }

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    inputData();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    requestNotificationPermissions();
    super.initState();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: uid != null ? const HomePage() : const LoginPage(),
    );
  }
}

List<Map<String, dynamic>> notificationsList = [];
Future<void> notification(
    void Function(Map<String, dynamic> data) setMessageData) async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    notificationsList.add(message.data);
    final jsonData = jsonEncode(notificationsList);
    await prefs.setString('notificationsList', jsonData);

    print('Got a message whilst in the foreground! $notificationsList');
    print('Got a message whilst in the foreground!');
    print('Message data:from ${message.from}');
    print('Message data: ${message.data}');
    print('Message data: ${message.data.runtimeType}');

    print('Message data: ${message.from}');
    print('Message data: ${message.messageId}');
    print('Message data type: ${message.data['type']}');

    if (message.data != null) {
      setMessageData(message.data);

      print('Message also contained a notification: ${message.notification}');
    }
  });
}

Future<void> notificationBackground(
    void Function(Map<String, dynamic> data) setMessageData) async {
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    final prefs = await SharedPreferences.getInstance();
    notificationsList.add(message.data);
    final jsonData = jsonEncode(notificationsList);
    await prefs.setString('notificationsList', jsonData);

    print('Got a message whilst in the background! $notificationsList');
    print('Got a message whilst in the background!');
    print('Message data: ${message.data}');
    print('Message data: ${message.data.runtimeType}');

    print('Message data: ${message.from}');
    print('Message data: ${message.messageId}');
    print('Message data type: ${message.data['type']}');

    if (message.data != null) {
      setMessageData(message.data);

      print('Message also contained a notification: ${message.notification}');
    }
  });
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.request();
  // if (status.isGranted) {
  //   // Notification permissions granted
  // } else if (status.isDenied) {
  //   // Notification permissions denied
  // } else if (status.isPermanentlyDenied) {
  //   // Notification permissions permanently denied, open app settings
  //   await openAppSettings();
  // }
}
