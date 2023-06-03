// ignore_for_file: no_logic_in_create_state, prefer__ructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_session/flutter_session.dart';

class VaccinatedPage extends StatefulWidget {
  const VaccinatedPage({super.key, required this.title});
  final String title;
  @override
  State<VaccinatedPage> createState() => _VaccinatedPageState(title);
}

class _VaccinatedPageState extends State<VaccinatedPage> {
  _VaccinatedPageState(this.title);
  final String title;
  late TextEditingController firstDoseController = new TextEditingController();
  late TextEditingController secondDoseController = new TextEditingController();
  late TextEditingController firstBoosterController =
      new TextEditingController();
  late TextEditingController secondBoosterController =
      new TextEditingController();
  late dynamic vaccineData;
  late bool isUserAdmin = false;
  @override
  void initState() {
    super.initState();
    FlutterSession().get("_isAdmin").then((value) {
      if (value != null) {
        isUserAdmin = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FlutterSession().get("_isAdmin"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            // width: MediaQuery.of(context).size.width / 1,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
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
                  Container(
                    // height: MediaQuery.of(context).size.height/2,
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Card(
                      elevation: 6,
                      child: Column(children: [
                        const Text(
                          "NUMBER VACCINES ADMINISTERED CATALUNAN GRANDE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        StreamBuilder<dynamic>(
                            stream: readVaccineData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data!;
                                vaccineData = data;
                                return Center(child: VaccineChart(data));
                              } else if (snapshot.hasError) {
                                return const Text("Error Retreiving Vaccine Data");
                              }
                              return const CircularProgressIndicator(
                                backgroundColor: Colors.redAccent,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.green),
                                strokeWidth: 10,
                              );
                            }),
                        Visibility(
                          visible: snapshot.data,
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: ElevatedButton.icon(
                                  onPressed: () {
                                    UpdateVaccineData(context, vaccineData);
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Update Vaccine Data")),
                            ),
                          ),
                        )
                      ]),
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Content()),
                ],
              ),
            ),
          );
        } else {
          return const Text("Loading");
        }
      },
    );
  }

  var date = '01/01/2023';
  var time = '05:00 PM';
  var firstDose = 12000;
  var secondDose = 15000;
  var firstBooster = 0;
  var secondBooster = 0;
  Widget Content() {
    return Column(children: [
      Container(
        child: DataTable(),
      ),
      Container(
          child: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          child: Visibility(
            visible: isUserAdmin,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        var dialogContext = context;
                        return UpdateRecord(dialogContext);
                      });
                },
                icon: const Icon(
                  // <-- Icon
                  Icons.add_box_rounded,
                  size: 24.0,
                ),
                label: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Update Record'),
                ), // <-- Text
              ),
            ),
          ),
        ),
      ))
    ]);
  }

  Widget DataTable() {
    var totalVaccinated = firstDose + secondDose + firstBooster + secondBooster;
    return StreamBuilder(
        stream: readVaccinated(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error Getting Data");
          } else if (snapshot.hasData) {
            var data = snapshot.data!;
            firstDose = data['first_dose'];
            secondDose = data['second_dose'];
            firstBooster = data['first_booster'];
            secondBooster = data['second_booster'];
            totalVaccinated =
                firstDose + secondDose + firstBooster + secondBooster;
            Timestamp asOf = data['as_of_date'];
            var dateTime = DateTime.fromMicrosecondsSinceEpoch(
                asOf.microsecondsSinceEpoch);
            date = DateFormat('MM/dd/yyyy, hh:mm a').format(dateTime);

            return SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Container(
                  margin: const EdgeInsets.all(8),
                  child: Center(
                      child: Column(//direction: Axis.vertical,
                          // ignore: prefer__literals_to_create_immutables
                          children: [
                    const Text(
                      "NUMBER OF VACCINATED PERSON IN CATALUNAN GRANDE",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    Text("CATALUNAN AS OF $date"),
                    Table(
                      border: TableBorder.all(),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            Container(
                                child: const Center(
                              child: Text("FIRST DOSE"),
                            )),
                            Container(
                              child: Center(child: Text("$firstDose")),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                                child: const Center(
                              child: Text("SECOND DOSE"),
                            )),
                            Container(
                              child: Center(child: Text("$secondDose")),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                                child: const Center(
                              child: Text("FIRST BOOSTER"),
                            )),
                            Container(
                              child: Center(child: Text("$firstBooster")),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                                child: const Center(
                              child: Text("SECOND BOOSTER"),
                            )),
                            Container(
                              child: Center(child: Text("$secondBooster")),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                                child: const Center(
                              child: Text("TOTAL VACCINATED"),
                            )),
                            Container(
                              child: Center(child: Text("$totalVaccinated")),
                            ),
                          ],
                        ),
                      ],
                    )
                  ]))),
            );
          } else {
            return const CircularProgressIndicator(
              backgroundColor: Colors.redAccent,
              valueColor: AlwaysStoppedAnimation(Colors.green),
              strokeWidth: 10,
            );
          }
        });
  }

  Widget UpdateRecord(BuildContext parent) {
    // ignore: unnecessary_new
    firstDoseController.text = firstDose.toString();
    secondDoseController.text = secondDose.toString();
    firstBoosterController.text = firstBooster.toString();
    secondBoosterController.text = secondBooster.toString();

    // ignore: unnecessary_new
    return new Dialog(
        elevation: 16,
        child: SizedBox(
            // height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width / 2,
            child: SingleChildScrollView(
                child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Text(
                          "UPDATE VACCINATED RECORD",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextFormField(
                        controller: firstDoseController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            hintText: "ENTER FIRST DOSE RECORD",
                            labelText: "FIRST DOSE",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      TextFormField(
                        controller: secondDoseController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            hintText: "ENTER SECOND DOSE RECORD",
                            labelText: "SECOND DOSE",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      TextFormField(
                        controller: firstBoosterController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            hintText: "ENTER FIRST BOOSTER RECORD",
                            labelText: "FIRST BOOSTER",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      TextFormField(
                        controller: secondBoosterController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            hintText: "ENTER SECOND BOOSTER RECORD",
                            labelText: "SECOND BOOSTER",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      Center(
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SizedBox(
                                          child: AlertDialog(
                                        title: const Text("Save Changes?"),
                                        actionsAlignment: MainAxisAlignment.end,
                                        actions: [
                                          ElevatedButton.icon(
                                              onPressed: () {
                                                SaveUpdatedRecord();
                                                Navigator.pop(parent);
                                              },
                                              icon: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.green,
                                              ),
                                              label: const Text("Publish")),
                                          ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.pop(parent);
                                              },
                                              icon: const Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                              ),
                                              label: const Text("Cancel"))
                                        ],
                                      ));
                                    },
                                  );
                                },
                                child: const Text("Save")),
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(parent);
                                },
                                child: const Text("Cancel"))
                          ],
                        ),
                      )
                    ])))));
  }

  Widget VaccineChart(dynamic data) {
    Map<String, double> chartValue = {
      'Pfizer - ${data['pfizer']}': data['pfizer'],
      'AztraZaneca - ${data['astrazeneca']}': data['astrazeneca'],
      'Covavax - ${data['covavax']}': data['covavax'],
      'Covaxin - ${data['covaxin']}': data['covaxin'],
      'Jansen - ${data['jansen']}': data['jansen'],
      'Moderna - ${data['moderna']}': data['moderna'],
      'Sinovac - ${data['sinovac']}': data['sinovac'],
      'Sputnik - ${data['sputnik']}': data['sputnik']
    };
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: PieChart(
          dataMap: chartValue,
          animationDuration: const Duration(milliseconds: 800),
          chartLegendSpacing: 20,
          chartRadius: MediaQuery.of(context).size.width / 8,
          // colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 30,
          centerText: "VACCINES",
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.rectangle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: true,
            decimalPlaces: 0,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ),
      ),
    );
  }

  Future UpdateVaccineData(BuildContext parent, dynamic data) {
    TextEditingController pfizerController =
        new TextEditingController(text: data['pfizer'].toString());
    TextEditingController astrazenecaController =
        new TextEditingController(text: data['astrazeneca'].toString());
    TextEditingController covavaxController =
        new TextEditingController(text: data['covavax'].toString());
    TextEditingController covaxinController =
        new TextEditingController(text: data['covaxin'].toString());
    TextEditingController jansenController =
        new TextEditingController(text: data['jansen'].toString());
    TextEditingController modernaController =
        new TextEditingController(text: data['moderna'].toString());
    TextEditingController sinovacController =
        new TextEditingController(text: data['sinovac'].toString());
    TextEditingController sputnikController =
        new TextEditingController(text: data['sputnik'].toString());
    return showDialog(
        context: parent,
        builder: (dialogContext) {
          return Dialog(
            elevation: 6,
            child: SizedBox(
                // height: MediaQuery.of(parent).size.height / 1.5,
                width: MediaQuery.of(parent).size.width / 2,
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 10),
                              child:
                                  const Text("UPDATE ADMINISTERED VACCINE RECORD")),
                          TextFormField(
                            controller: pfizerController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER PFIZER ADMINISTERED",
                                labelText: "PFIZER",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: astrazenecaController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER ASTRAZENECA ADMINISTERED",
                                labelText: "ASTRAZENECA",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: covavaxController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER COVAVAX ADMINISTERED",
                                labelText: "COVAVAX",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: covaxinController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER COVAXIN ADMINISTERED",
                                labelText: "COVAXIN",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: jansenController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER JANSEN ADMINISTERED",
                                labelText: "JANSEN",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: modernaController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER MODERNA ADMINISTERED",
                                labelText: "MODERNA",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: sinovacController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER SINOVAC ADMINISTERED",
                                labelText: "SINOVAC",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: sputnikController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER SPUTNIK ADMINISTERED",
                                labelText: "SPUTNIK",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      var data = {
                                        'astrazeneca': int.parse(
                                            astrazenecaController.text),
                                        'covavax':
                                            int.parse(covavaxController.text),
                                        'covaxin':
                                            int.parse(covaxinController.text),
                                        'jansen':
                                            int.parse(jansenController.text),
                                        'moderna':
                                            int.parse(modernaController.text),
                                        'pfizer':
                                            int.parse(pfizerController.text),
                                        'sinovac':
                                            int.parse(sinovacController.text),
                                        'sputnik':
                                            int.parse(sputnikController.text)
                                      };
                                      showDialog(
                                        context: context,
                                        builder: (dlgContext) {
                                          return SizedBox(
                                              child: AlertDialog(
                                            title: const Text("Save Changes?"),
                                            actionsAlignment:
                                                MainAxisAlignment.end,
                                            actions: [
                                              ElevatedButton.icon(
                                                  onPressed: () {
                                                    SaveUpdatedVaccineData(
                                                        data);
                                                    Navigator.pop(
                                                        dialogContext);
                                                  },
                                                  icon: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.green,
                                                  ),
                                                  label: const Text("Publish")),
                                              ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        dialogContext);
                                                  },
                                                  icon: const Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                  ),
                                                  label: const Text("Cancel"))
                                            ],
                                          ));
                                        },
                                      );
                                    },
                                    child: const Text("Save")),
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text("Cancel"))
                              ],
                            ),
                          )
                        ]),
                  ),
                )),
          );
        });
  }

  Stream<dynamic> readVaccinated() {
    try {
      return FirebaseFirestore.instance
          .collection('Vaccinated')
          .doc('Data')
          .snapshots();
    } catch (e) {
      throw new Exception();
    }
  }

  Stream<dynamic> readVaccineData() {
    return FirebaseFirestore.instance
        .collection('Vaccinated')
        .doc('Vaccines')
        .snapshots();
  }

  void SaveUpdatedRecord() {
    final docVaccinated =
        FirebaseFirestore.instance.collection('Vaccinated').doc('Data');
    docVaccinated.update({
      'first_dose': int.tryParse(firstDoseController.text),
      'second_dose': int.tryParse(secondDoseController.text),
      'first_booster': int.tryParse(firstBoosterController.text),
      'second_booster': int.tryParse(secondBoosterController.text),
      'as_of_date': Timestamp.fromDate(DateTime.now())
    });
  }

  void SaveUpdatedVaccineData(dynamic data) {
    final docVaccineData =
        FirebaseFirestore.instance.collection('Vaccinated').doc('Vaccines');
    docVaccineData.update(data);
  }
}
