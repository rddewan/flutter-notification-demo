import 'package:flutter/material.dart';

class NotificationPayloadScreen extends StatelessWidget {
  const NotificationPayloadScreen({Key? key,required this.payload}) : super(key: key);

  final String? payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:  Center(
      child: Column(
        children: [
          Text(payload.toString()),
        ],
      ),
      ),
    );
  }
}