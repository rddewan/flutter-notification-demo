
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

AndroidNotificationDetails androidPlatformChannelHigh(
  {required String id,required String name, required String description,required String ticker}
) =>
  AndroidNotificationDetails(
    id,
    name,
    channelDescription: description,
    importance: Importance.max,
    priority: Priority.high,
    ticker: ticker
  );

AndroidNotificationDetails androidPlatformChannelLow(
  {required String id,required String name, required String description,required String ticker}
) =>
  AndroidNotificationDetails(
    id,
    name,
    channelDescription: description,
    importance: Importance.low,
    priority: Priority.low,
    ticker: ticker
  );

  AndroidNotificationDetails androidPlatformChannelBigPicture(
  {
    required String id,
    required String name, 
    required String description,
    required String ticker,
    required BigPictureStyleInformation bigPictureStyleInformation,
  }
) =>
  AndroidNotificationDetails(
    id,
    name,
    channelDescription: description,
    importance: Importance.high,
    priority: Priority.high,
    ticker: ticker,
    styleInformation: bigPictureStyleInformation,
    channelShowBadge: true
  );

  AndroidNotificationDetails androidPlatformChannelBadge(
  {
    required String id,
    required String name, 
    required String description,
    required String ticker,    
  }
) =>
  AndroidNotificationDetails(
    id,
    name,
    channelDescription: description,
    importance: Importance.high,
    priority: Priority.high,
    ticker: ticker,    
    channelShowBadge: true,
  );