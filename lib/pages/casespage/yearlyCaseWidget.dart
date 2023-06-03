import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YearlyCase extends StatefulWidget {
  const YearlyCase({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<YearlyCase> createState() => _YearlyCase(isAdmin);
}

class _YearlyCase extends State<YearlyCase> {
  _YearlyCase(this.isAdmin);
  late TrackballBehavior _trackballBehavior;
  final bool isAdmin;
  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
        // Enables the trackball
        enable: true,
        tooltipSettings: const InteractiveTooltip(
            enable: true, color: Colors.red, format: 'point.y Cases'),
        lineWidth: 2,
        lineType: TrackballLineType.horizontal,
        activationMode: ActivationMode.singleTap,
        tooltipAlignment: ChartAlignment.near,
        tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
        shouldAlwaysShow: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Text("Yearly Cases"),
          ),
        ),
        StreamBuilder<List<SalesData>>(
            stream: GetYearlyCases(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<SalesData> data = [];
                data.add(SalesData("2018", 0));
                data.add(SalesData("2019", 0));
                data.addAll(snapshot.data!);
                return Column(
                  children: [
                    Container(
                      child: Visibility(
                        visible: isAdmin,
                        child: ElevatedButton(
                          child: const Text("Update Yearly Cases Data"),
                          onPressed: () {
                            String selectedYear = data.last.year;
                            String count = data.last.sales.toString();
                            List<SalesData> list = data;
                            TextEditingController countValue =
                                TextEditingController(text: count);
                            TextEditingController yearValue =
                                TextEditingController();
                            showDialog(
                              context: context,
                              builder: (dlgcontext) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Dialog(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 20, bottom: 5),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                const Text("Update Yearly Data"),
                                                Container(
                                                  child: DropdownButton<String>(
                                                    value: selectedYear,
                                                    items: list.map((e) {
                                                      return DropdownMenuItem<
                                                              String>(
                                                          value: e.year,
                                                          child: Text(e.year));
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedYear = value!;
                                                        countValue.text = data
                                                            .where((element) =>
                                                                element.year ==
                                                                selectedYear)
                                                            .first
                                                            .sales
                                                            .toString();
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(dlgcontext)
                                                              .size
                                                              .width /
                                                          5,
                                                  child: Container(
                                                    child: TextFormField(
                                                      controller: countValue,
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Container(
                                                    margin: const EdgeInsets.only(
                                                        top: 20),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                  right: 5),
                                                          child: ElevatedButton(
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (subcontext) {
                                                                    return Dialog(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                5,
                                                                        width:
                                                                            MediaQuery.of(context).size.width /
                                                                                2,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Container(
                                                                              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                                                                              child: TextFormField(controller: yearValue, decoration: const InputDecoration(labelText: "Enter Year")),
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.only(top: 20),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Container(
                                                                                    margin: const EdgeInsets.only(right: 5),
                                                                                    child: ElevatedButton(
                                                                                        onPressed: () {
                                                                                          CreateYearlyCases(year: yearValue.text);
                                                                                          setState(() => list.add(SalesData(yearValue.text, 0)));
                                                                                          Navigator.pop(dlgcontext);
                                                                                        },
                                                                                        child: const Text("Save")),
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(subcontext);
                                                                                      },
                                                                                      child: const Text("Cancel"))
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: const Text(
                                                                  "Add Year")),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                  right: 5),
                                                          child: ElevatedButton(
                                                              onPressed: () {
                                                                UpdateYearlyCases(
                                                                    id: selectedYear,
                                                                    data: {
                                                                      'count': double.parse(
                                                                          countValue
                                                                              .text)
                                                                    });
                                                                Navigator.pop(
                                                                    dlgcontext);
                                                              },
                                                              child:
                                                                  const Text("Save")),
                                                        ),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  dlgcontext);
                                                            },
                                                            child:
                                                                const Text("Cancel")),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SfCartesianChart(
                        // Initialize category axis
                        primaryXAxis: CategoryAxis(),
                        trackballBehavior: _trackballBehavior,
                        series: <AreaSeries<SalesData, String>>[
                          AreaSeries<SalesData, String>(
                              // Bind data source
                              dataSource: data,
                              xValueMapper: (SalesData sales, _) => sales.year,
                              yValueMapper: (SalesData sales, _) => sales.sales)
                        ]),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return const CircularProgressIndicator(
                  backgroundColor: Colors.redAccent,
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                  strokeWidth: 10,
                );
              }
            })
      ],
    ));
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;

  static SalesData fromJson(Map<String, dynamic> json) {
    return SalesData(json['year'], json['count']);
  }
}

Future CreateYearlyCases({required year}) async {
  final doc = FirebaseFirestore.instance.collection(collectionPath).doc(year);

  final json = {'year': year, 'count': 0};
  await doc.set(json);
}

Future UpdateYearlyCases({required id, dynamic data}) async {
  final hub = FirebaseFirestore.instance.collection(collectionPath).doc(id);
  await hub.set(data, SetOptions(merge: true));
}

const collectionPath = 'YearlyCases';
Stream<List<SalesData>> GetYearlyCases() {
  return FirebaseFirestore.instance.collection(collectionPath).snapshots().map(
      (event) => event.docs.map((e) => SalesData.fromJson(e.data())).toList());
}
