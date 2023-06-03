// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class VariantPage extends StatefulWidget {
  const VariantPage({super.key, required this.title});
  final String title;
  @override
  State<VariantPage> createState() => _VariantPageState(title);
}

class _VariantPageState extends State<VariantPage> {
  _VariantPageState(this.title);
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
