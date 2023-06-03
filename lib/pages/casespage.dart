// ignore_for_file: no_logic_in_create_state, unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key, required this.title});
  final String title;
  @override
  State<CasesPage> createState() => _CasesPageState(title);
}

class _CasesPageState extends State<CasesPage> {
  _CasesPageState(this.title);
  final String title;
  late Future<List<Cases>> cases;
  @override
  void initState() {
    super.initState();
    // myNews = GetNews();
    cases = getCases();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
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
      ),
      const SizedBox(
          child: Text(
        'Total Number of Covid-19 Cases in the Baranggay',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      )),
      SizedBox(
        child: FutureBuilder<List<Cases>>(
            future: cases,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Baranggay',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Recovery',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Death',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    ],
                    rows: List<DataRow>.from(
                        snapshot.data!.map((e) => DataRow(cells: [
                              DataCell(Text(e.id)),
                              DataCell(Text(
                                  "${snapshot.data!.where((element) => element.id == e.id && e.caseStatus.toUpperCase() == 'RECOVERY').length}")),
                              DataCell(Text(
                                  "${snapshot.data!.where((element) => element.id == e.id && e.caseStatus.toUpperCase() == 'DEATH').length}")),
                              DataCell(Text(
                                  "${snapshot.data!.where((element) => element.id == e.id).length}"))
                            ]))));
              } else if (snapshot.hasError) {
                return const Text('Error Loading Image');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            }),
      )
    ]);
  }

  Future<List<Cases>> getCases() async {
    List<Cases> result = [];

    final cases =
        await FirebaseFirestore.instance.collection('CovidCases').get();

    for (var element in cases.docs) {
      result.add(Cases.fromJson(element.data(), element.id));
    }

    debugPrint(result.toString());

    return result;
  }
}

class Cases {
  late String id;
  late String caseStatus;
  late String createdAt;
  late String createdBy;

  Cases(this.id, this.caseStatus, this.createdAt, this.createdBy);

  static Cases fromJson(Map<String, dynamic> json, String id) =>
      Cases(id, json['caseStatus'], json['createdAt'], json['createdBy']);
}
