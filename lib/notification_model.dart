import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    this.details,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
  final NotificationDetails? details;

}