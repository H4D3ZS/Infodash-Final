// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class SwabCenterPage extends StatefulWidget {
  const SwabCenterPage({super.key, required this.title});
  final String title;
  @override
  State<SwabCenterPage> createState() => _SwabCenterPageState(title);
}

class _SwabCenterPageState extends State<SwabCenterPage> {
  _SwabCenterPageState(this.title);
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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
