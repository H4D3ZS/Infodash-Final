// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class VaccinatedPage extends StatefulWidget {
  const VaccinatedPage({super.key, required this.title});
  final String title;
  @override
  State<VaccinatedPage> createState() => _VaccinatedPageState(title);
}

class _VaccinatedPageState extends State<VaccinatedPage> {
  _VaccinatedPageState(this.title);
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
