import 'dart:async';

import 'package:engro/firebase_options.dart';
import 'package:engro/notifications_services.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AppBuilder = Future<Widget> Function(
  SharedPreferences sharedPreferences,
);

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatecounter') {
    int counter = 0;
    await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0)
        .then((value) {
      counter = value!;
      counter++;
    });
    await HomeWidget.saveWidgetData<int>('_counter', counter);
    await HomeWidget.updateWidget(
        //this must the class name used in .Kt
        name: 'HomeScreenWidgetProvider',
        iOSName: 'HomeScreenWidgetProvider');
  }
}

Future<void> bootstrap(AppBuilder builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  await Firebase.initializeApp(
    name: "engro_buzz",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // if (!kDebugMode) {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: AndroidProvider.playIntegrity,
  //     appleProvider: AppleProvider.appAttest,
  //   );
  // } else {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: AndroidProvider.debug,
  //     appleProvider: AppleProvider.debug,
  //   );
  // }

  final sharedPreferences = await SharedPreferences.getInstance();
  NotificationServices notificationServices = NotificationServices();

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    notificationServices.showNotification(message);

    print("Handling a background message: ${message.messageId}");

    // Handle background message here
  }

  //initialize plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationChannel channel = const AndroidNotificationChannel(
      //for notificaiton initialization
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
      showBadge: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('engro_buzz'));
  await runZonedGuarded<Future<void>>(
    () async {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      runApp(
        await builder(sharedPreferences),
      );
    },
    FirebaseCrashlytics.instance.recordError,
  );
}
