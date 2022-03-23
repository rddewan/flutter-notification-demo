import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_notification/notification_model.dart';
import 'package:flutter_notification/notification_payload.dart';
import 'package:flutter_notification/scheduled_notification_screen.dart';
import 'package:flutter_notification/util/android_notification_channel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

final BehaviorSubject<NotificationModel> didReceiveLocalNotificationSubject =
  BehaviorSubject<NotificationModel>();

final BehaviorSubject<String?> selectNotificationSubject =
  BehaviorSubject<String?>();

String? selectedNotificationPayload;

Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('A background message just showed up :  ${message.messageId}');
}

    
void main() async {  
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await _configureLocalTimeZone();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: (
            int id,
            String? title,
            String? body,
            String? payload,
          ) async {
            didReceiveLocalNotificationSubject.add(
              NotificationModel(
                id: id,
                title: title,
                body: body,
                payload: payload,
              ),
            );
          });

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,    
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');        
      }
      //selectedNotificationPayload = payload;
      selectNotificationSubject.add(payload);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(       
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key); 

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((NotificationModel receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        NotificationPayloadScreen(payload: receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }
  
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.push(
        context, MaterialPageRoute(builder: (_) => 
          NotificationPayloadScreen(payload: payload)));
    });
  }

  @override
  void initState() {   
    super.initState();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();

    // Returns a Stream that is called when an incoming FCM payload is 
    // received whilst the Flutter instance is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showSimpleNotification(
          NotificationModel(
            id: notification.hashCode, 
            title: notification.title,
            body: notification.body, 
            payload: notification.body)
        );        
      }
    });

    //Returns a [Stream] that is called when a user presses a notification message displayed via FCM.
    // A Stream event will be sent if the app has opened from a background state (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title ?? ''),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body ?? '')],
                  ),
                ),
              );
            });
      }
    });

  }

  @override
  void dispose() {
    selectNotificationSubject.drain();
    selectNotificationSubject.close();
    didReceiveLocalNotificationSubject.drain();
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(        
        title: Text(widget.title),
      ),
      body: Center(       
        child: Column(          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                showSimpleNotification(NotificationModel(
                  id: 100, 
                  title: 'Simple Notification', 
                  body: 'This is a body of simple notification', 
                  payload: 'This is a payload for simple notification'
                ),
              );

              }, 
              child: const Text('Simple Notification')),
            ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduledNotificationScreen()));
            },          
            child: const Text('Schedule Notification Page'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> showSimpleNotification(NotificationModel notification) async {
    return flutterLocalNotificationsPlugin.show(
      notification.id, 
      notification.title, 
      notification.body, 
      NotificationDetails(
        android: androidPlatformChannelHigh(
          id: '1', 
          name: 'first notification', 
          description: 'this is first notification description', 
          ticker: 'local notification'
        ),
        iOS: const IOSNotificationDetails()
      ),
      payload: notification.payload
    );

  }

  
  
}
