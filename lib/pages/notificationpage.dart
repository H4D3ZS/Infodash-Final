// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({super.key, required this.title});
  final String title;
  @override
  State<NotificationPage> createState() => _NotificationPageState(title);
}

class _NotificationPageState extends State<NotificationPage> {
  _NotificationPageState(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
