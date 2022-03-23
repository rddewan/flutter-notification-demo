
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_notification/main.dart';
import 'package:flutter_notification/notification_model.dart';
import 'package:flutter_notification/util/android_notification_channel.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

class ScheduledNotificationScreen extends StatefulWidget {
  const ScheduledNotificationScreen({Key? key}) : super(key: key);

  @override
  State<ScheduledNotificationScreen> createState() => _ScheduledNotificationScreen();
}

class _ScheduledNotificationScreen extends State<ScheduledNotificationScreen> {
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Notification'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _zonedScheduleNotification();              
              }, 
              child: const Text('Schedule Notification After 5 Sec')),
            ElevatedButton(
              onPressed: () {
                _repeatNotification();              
              }, 
              child: const Text('Schedule Notification Every 1 Min')),
            ElevatedButton(
              onPressed: () {
                _showBigPictureNotificationURL();              
              }, 
              child: const Text('Big Picture Style')),
            ElevatedButton(
              onPressed: () {
                _showNotificationWithIconBadge();              
              }, 
              child: const Text('Notification with badge')),
          ],
        ),
      ),
    );
  }

  void showScheduleNotification(NotificationModel notificationModel) {

  }

  // show notification in 5 sec
  Future<void> _zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title 5 sec',
        'scheduled body 5 sec',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        NotificationDetails(
          android: androidPlatformChannelLow(
            id: '1', 
            name: 'first notification', 
            description: 'this is first notification description', 
            ticker: 'local notification'
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _repeatNotification() async {   
    
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(
          android: androidPlatformChannelLow(
            id: '2', 
            name: 'second notification', 
            description: 'this is second notification description', 
            ticker: 'local notification'
          ),);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      1, 
      'repeating title every 1 min',
      'repeating body every 1 min',
       RepeatInterval.everyMinute, 
       platformChannelSpecifics,
      androidAllowWhileIdle: true);
  }

  Future<void> _scheduleWeeklyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id',
              'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleWeeklyMondayTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id',
              'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _showBigPictureNotificationURL() async {
    final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(
        await _getByteArrayFromUrl('https://via.placeholder.com/48x48'));
    final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
        await _getByteArrayFromUrl('https://via.placeholder.com/400x800'));

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
          bigPicture,
          largeIcon: largeIcon,
          contentTitle: 'overridden <b>big</b> content title',
          htmlFormatContentTitle: true,
          summaryText: 'summary <i>text</i>',
          htmlFormatSummaryText: true);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        androidPlatformChannelBigPicture(
          id: '3', 
          name: 'third notification', 
          description: 'this is third notification description', 
          ticker: 'local notification',
          bigPictureStyleInformation: bigPictureStyleInformation
        );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const IOSNotificationDetails()
        );
    await flutterLocalNotificationsPlugin.show(
        3, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<void> _showNotificationWithIconBadge() async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(badgeNumber: 1);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        androidPlatformChannelBadge(
          id: '3', 
          name: 'third notification', 
          description: 'this is third notification description', 
          ticker: 'local notification',          
        );
    
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);    

    await flutterLocalNotificationsPlugin.show(
        4, 'icon badge title', 'icon badge body', platformChannelSpecifics,
        payload: 'item x');

    var isSupported = await FlutterAppBadger.isAppBadgeSupported();
    if (isSupported) {
      FlutterAppBadger.updateBadgeCount(5);
    }
    
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMondayTenAM() {
    tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );    
  }
}