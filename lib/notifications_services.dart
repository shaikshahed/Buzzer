import 'dart:io';
import 'dart:math';

import 'package:engro/buzz_request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }
  //function to initialise flutter local notification plugin to show notifications for android when app is active
  // void initLocalNotifications(BuildContext context, RemoteMessage message)async{
  //   var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iosInitializationSettings = const DarwinInitializationSettings();

  //   var initializationSetting = InitializationSettings(
  //       android: androidInitializationSettings ,
  //       iOS: iosInitializationSettings,

  //   );

  //   await _flutterLocalNotificationsPlugin.initialize(
  //       initializationSetting,
  //     onDidReceiveNotificationResponse: (payload){
  //         // handle interaction when app is active for android
  //         try{
  //           handleMessage(context, message);
  //           print("handle");
  //           }catch(e){
  //           Utils().toastMessage(e.toString());
  //           print("error in initlocal");
  //         }
  //     },

  //   );
  // }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    try {
      if (message == null) {
        print("Remote message is null");
        return;
      }

      var androidInitializationSettings =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();

      var initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      if (_flutterLocalNotificationsPlugin == null) {
        print("_flutterLocalNotificationsPlugin is null");
        return;
      }

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
          // Handle notification when the app is in the foreground
          try {
            handleMessage(context, message);
            print("handle");
          } catch (e) {
            print("Error handling notification: $e");
          }
        },
      );
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
        // handleMessage(context, message);
      }
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
        message.notification!.android!.channelId.toString(),
        importance: Importance.max,
        showBadge: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('engro_buzz'));
    print("channel id ${message.notification!.android!.channelId.toString()}");
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            ticker: 'ticker',
            // sound: channel.sound
            sound: RawResourceAndroidNotificationSound('engro_buzz')
            //  icon: largeIconPath
            );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

//  // Listen for messages received while the app is in the foreground
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     handleMessage(context, message);
//   });

//     //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    // Extract necessary data from the message

    try {
      String name = message.data['name'] ?? '';
      String number = message.data['number'] ?? '';
      print("name $name");
      print("number $number");

      // Navigate to the ReceiveNotification page with the extracted data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuzzRequest(name: name, phoneNumber: number),
        ),
      );
    } catch (e) {
      // Utils().toastMessage("Error in handleMessage: $e");
      print("Error in handleMessage: $e");
    }

    // if(message.data['type'] =='msj'){
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => MessageScreen(
    //         id: message.data['id'] ,
    //       )));
    // }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

//   Future<void> forgroundMessage() async {
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
// }
}
