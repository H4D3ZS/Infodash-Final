// ignore_for_file: no_logic_in_create_state, prefer__literals_to_create_immutables, prefer__ructors

import 'package:flutter/material.dart';
import 'casespage/addCaseWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infodash_app/infodashlib/Common/SessionHandler.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:infodash_app/home.dart';
import 'package:infodash_app/infodashlib/Cases/CasesInfoManager.dart';
import 'package:infodash_app/infodashlib/Cases/CasesInfo.dart';
import 'package:infodash_app/infodashlib/Cases/CaseStatus.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:pie_chart/pie_chart.dart';
import 'casespage/yearlyCaseWidget.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key, required this.title});
  final String title;
  @override
  State<CasesPage> createState() => _CasesPageState(title);
}

class _CasesPageState extends State<CasesPage> {
  _CasesPageState(this.title);

  final recordManager = CasesInfoManager();
  bool isUserAdmin = false;
  final String title;
  late Future<List<Cases>> cases;
  late Future<bool> isAdmin;
  bool searchVisible = false;

  final searchController = TextEditingController();
  TextEditingController baranggay = TextEditingController();
  var baranggayList = CasesInfoManager().GetBaranggayList();

  @override
  void initState() {
    super.initState();
    isAdmin = SessionHandler().isAdmin();
    // myNews = GetNews();
    cases = getCases();
    FlutterSession().get("_isAdmin").then((value) {
      if (value != null) {
        isUserAdmin = value;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    baranggay.dispose();
    super.dispose();
  }

  refresh() {
    setState(() {
      CasesInfoManager().baranggayList = null;
      baranggayList = CasesInfoManager().GetBaranggayList();
    });
  }

  bool isUnsafe = false;

  updateUnsafe(value) {
    setState(() {
      isUnsafe = value;
    });
  }

  ScrollController horizontalScroll = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Material(
          child: Column(children: [
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.all(20),
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

            // Visibility(
            //   visible: false,
            //   child: SizedBox(
            //       height: 50,
            //       width: MediaQuery.of(context).size.width / 5,
            //       child: TextField(
            //         controller: searchController,
            //         decoration:
            //              InputDecoration(labelText: 'Search Subdivision'),
            //       )),
            // ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: SingleChildScrollView(
                  child: FutureBuilder<List<CasesRecord>>(
                      future: recordManager.GetCasesRecords(),
                      builder: (context, snapshot) {
                        var year = DateTime.now().year;
                        if (snapshot.hasData) {
                          Map<String, double> chartValue = {};
                          for (var element in snapshot.data!) {
                            chartValue.addAll({
                              element.BaranggayName:
                                  element.TotalCount.toDouble()
                            });
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'Total Number of Covid-19 Cases in Catalunan Grande',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                              YearlyCase(
                                isAdmin: isUserAdmin,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 20, bottom: 40),
                                child: const Text('All-Time Detailed Cases'),
                              ),
                              SizedBox(
                                child: SingleChildScrollView(
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: PieChart(
                                        dataMap: chartValue,
                                        animationDuration:
                                            const Duration(milliseconds: 800),
                                        chartLegendSpacing: 20,
                                        chartRadius: 400,
                                        // colorList: colorList,
                                        initialAngleInDegree: 0,
                                        chartType: ChartType.disc,
                                        ringStrokeWidth: 30,
                                        centerText: "COVID CASES",
                                        legendOptions: const LegendOptions(
                                          showLegendsInRow: false,
                                          legendPosition: LegendPosition.bottom,
                                          showLegends: true,
                                          legendShape: BoxShape.rectangle,
                                          legendTextStyle: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        chartValuesOptions:
                                            const ChartValuesOptions(
                                          showChartValueBackground: true,
                                          showChartValues: true,
                                          showChartValuesInPercentage: false,
                                          showChartValuesOutside: true,
                                          decimalPlaces: 0,
                                        ),
                                        // gradientList: ---To add gradient colors---
                                        // emptyColorGradient: ---Empty Color gradient---
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  controller: horizontalScroll,
                                  child: SingleChildScrollView(
                                    controller: horizontalScroll,
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                        columns: <DataColumn>[
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Marking',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Subdivision',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Active',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Suspected',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Recovery',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Death',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Total',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Visibility(
                                              visible: isUserAdmin,
                                              child: const Expanded(
                                                child: Text(
                                                  'Options',
                                                  style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                        rows: List<DataRow>.from(
                                            snapshot.data!.map((e) {
                                          return DataRow(cells: [
                                            DataCell(Tooltip(
                                              message: e.Marking!.toUpperCase(),
                                              child: Center(
                                                child: Icon(
                                                  Icons.flag_circle,
                                                  color: e.Marking == 'safe'
                                                      ? Colors.blue[800]
                                                      : Colors.red[600],
                                                ),
                                              ),
                                            )),
                                            DataCell(Tooltip(
                                              message: "Click to view logs",
                                              child: TextButton(
                                                child: Text(e.BaranggayName),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return LogDialog(
                                                          context, e);
                                                    },
                                                  );
                                                },
                                              ),
                                            )),
                                            DataCell(Tooltip(
                                              richMessage: TextSpan(
                                                  text:
                                                      "Initial Active Case : ${e.ActiveCaseCount} ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "Reported Active Case : ${e.CaseInfo.where((element) => element.Status == CaseStatus.active && element.DateVerified != null).length}")
                                                  ]),
                                              child: Text(
                                                  "${e.CaseInfo.where((element) => element.Status == CaseStatus.active && element.DateVerified != null).length + e.ActiveCaseCount} "),
                                            )),
                                            DataCell(Tooltip(
                                              richMessage: TextSpan(
                                                  text:
                                                      "Initial Suspected Case : ${e.SuspectedCaseCount} ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "Reported Suspected Case : ${e.CaseInfo.where((element) => element.Status == CaseStatus.suspected && element.DateVerified != null).length}")
                                                  ]),
                                              child: Text(
                                                  "${e.CaseInfo.where((element) => element.Status == CaseStatus.suspected && element.DateVerified != null).length + e.SuspectedCaseCount}"),
                                            )),
                                            DataCell(Tooltip(
                                              richMessage: TextSpan(
                                                  text:
                                                      "Initial Recovery Case : ${e.RecoveryCount} ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "Reported Recovery Case : ${e.CaseInfo.where((element) => element.Status == CaseStatus.recovered && element.DateVerified != null).length}")
                                                  ]),
                                              child: Text(
                                                  "${e.CaseInfo.where((element) => element.Status == CaseStatus.recovered && element.DateVerified != null).length + e.RecoveryCount}"),
                                            )),
                                            DataCell(Tooltip(
                                              richMessage: TextSpan(
                                                  text:
                                                      "Initial Death Case : ${e.DeathCount} ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "Reported Death Case : ${e.CaseInfo.where((element) => element.Status == CaseStatus.death && element.DateVerified != null).length}")
                                                  ]),
                                              child: Text(
                                                  "${e.CaseInfo.where((element) => element.Status == CaseStatus.death && element.DateVerified != null).length + e.DeathCount}"),
                                            )),
                                            DataCell(Text(
                                                "${e.CaseInfo.where((element) => element.DateVerified != null).length + e.TotalCount}")),
                                            DataCell(Visibility(
                                              visible: isUserAdmin,
                                              child: Container(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (dialogContext) {
                                                                  return UpdateBaranggayDialog(
                                                                      dialogContext,
                                                                      e);
                                                                });
                                                          },
                                                          icon: Icon(
                                                            Icons.mode_edit,
                                                            color: Colors
                                                                .yellow[500],
                                                          )),
                                                      // ButtonTheme(
                                                      //   minWidth: 50,
                                                      //   // child: ElevatedButton(
                                                      //   //     onPressed: () {
                                                      //   //       String marking = "safe";
                                                      //   //       if (e.Marking ==
                                                      //   //           "safe") {
                                                      //   //         marking = "unsafe";
                                                      //   //       }
                                                      //   //       recordManager
                                                      //   //           .UpdateBaranggayMarking(
                                                      //   //               e.BaranggayName,
                                                      //   //               marking);
                                                      //   //       Navigator.of(context).push(
                                                      //   //           new MaterialPageRoute(
                                                      //   //               builder:
                                                      //   //                   (BuildContext
                                                      //   //                       context) {
                                                      //   //         return new Home(
                                                      //   //           current_page:
                                                      //   //               'Covid-19 Cases',
                                                      //   //         );
                                                      //   //       }));
                                                      //   //     },
                                                      //   //     child: Text(
                                                      //   //       "Mark ${e.Marking!.toUpperCase() == 'SAFE' ? "Unsafe" : "Safe"}",
                                                      //   //       style: TextStyle(
                                                      //   //           fontSize: 10),
                                                      //   //     )),
                                                      // )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ))
                                          ]);
                                        }))),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return const Text('Error Loading Data');
                        }

                        // By default, show a loading spinner.
                        return const CircularProgressIndicator(
                          backgroundColor: Colors.redAccent,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                          strokeWidth: 10,
                        );
                      }),
                ),
              ),
            ),
            FutureBuilder<bool>(
                future: isAdmin,
                builder: (context, snapshot) {
                  refresh() {
                    setState(() {
                      CasesInfoManager().baranggayList = null;
                      baranggayList = CasesInfoManager().GetBaranggayList();
                    });
                  }

                  var isAdmin = false;
                  if (snapshot.hasData) {
                    if (snapshot.data!) {
                      isAdmin = true;
                    }
                  }
                  return Visibility(
                      visible: isAdmin,
                      child: AddCase(
                          notifyParent: refresh, baranggays: baranggayList));
                }),
          ]),
        ),
      ),
    );
  }

  Widget UpdateBaranggayDialog(BuildContext dialogContext, CasesRecord data) {
    Color getColor(Set<MaterialState> states) {
      Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    late TextEditingController baranggayController = TextEditingController();
    late TextEditingController initialActiveController =
        TextEditingController();
    late TextEditingController initialSuspectedController =
        TextEditingController();
    late TextEditingController initialRecoveryController =
        TextEditingController();
    late TextEditingController initialDeathController = TextEditingController();

    baranggayController.text = data.BaranggayName;
    initialActiveController.text = data.ActiveCaseCount.toString();
    initialSuspectedController.text = data.SuspectedCaseCount.toString();
    initialRecoveryController.text = data.RecoveryCount.toString();
    initialDeathController.text = data.DeathCount.toString();
    bool isValid = false;
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 16,
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 1.5,
          // width: MediaQuery.of(context).size.width,
          child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                margin: const EdgeInsets.all(8),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 15),
                      child: Text(
                        "MODIFY ${data.BaranggayName.toUpperCase()}",
                        style: const TextStyle(
                            fontSize: 26.0,
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto"),
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              initialActiveController.text =
                                  (int.parse(initialActiveController.text) - 1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(dialogContext).size.width / 4,
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              controller: initialActiveController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                  hintText: "ENTER ACTIVE CASE INITIAL VALUE",
                                  labelText: "ACTIVE CASE",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              initialActiveController.text =
                                  (int.parse(initialActiveController.text) + 1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              initialSuspectedController.text =
                                  (int.parse(initialSuspectedController.text) -
                                          1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(dialogContext).size.width / 4,
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              controller: initialSuspectedController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                  hintText:
                                      "ENTER SUSPECTED CASE INITIAL VALUE",
                                  labelText: "SUSPECTED CASE",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              initialSuspectedController.text =
                                  (int.parse(initialSuspectedController.text) +
                                          1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              initialRecoveryController.text =
                                  (int.parse(initialRecoveryController.text) -
                                          1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(dialogContext).size.width / 4,
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              controller: initialRecoveryController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                  hintText: "ENTER RECOVERY CASE INITIAL VALUE",
                                  labelText: "RECOVERY CASE",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              initialRecoveryController.text =
                                  (int.parse(initialRecoveryController.text) +
                                          1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              initialDeathController.text =
                                  (int.parse(initialDeathController.text) - 1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(dialogContext).size.width / 4,
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              controller: initialDeathController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                  hintText: "ENTER DEATH CASE INITIAL VALUE",
                                  labelText: "DEATH CASE",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              initialDeathController.text =
                                  (int.parse(initialDeathController.text) + 1)
                                      .toString();
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center(child: SizedBox(height: 10)),
                    // Row(
                    //   children: <Widget>[
                    //     SizedBox(
                    //       width: 10,
                    //     ), //SizedBox
                    //     Text(
                    //       'MARK AS UNSAFE',
                    //       style: TextStyle(fontSize: 17.0),
                    //     ), //Text
                    //     SizedBox(width: 10), //SizedBox
                    //     /** Checkbox Widget **/
                    //     Checkbox(
                    //       checkColor: Colors.white,
                    //       fillColor:
                    //           MaterialStateProperty.resolveWith(getColor),
                    //       value: isUnsafe,
                    //       onChanged: (bool? value) {
                    //         updateUnsafe(value);
                    //       },
                    //     )
                    //   ], //<Widget>[]
                    // ), //Row
                    // SizedBox(
                    //     width: MediaQuery.of(dialogContext).size.width / 3 - 10,
                    //     child: Checkbox(
                    //       checkColor: Colors.white,
                    //       fillColor:
                    //           MaterialStateProperty.resolveWith(getColor),
                    //       value: isUnsafe,
                    //       onChanged: (bool? value) {
                    //         setState(() {
                    //           isUnsafe = value!;
                    //         });
                    //       },
                    //     )),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                final newData = {
                                  'initial_active': int.tryParse(
                                              initialActiveController.text) ==
                                          null
                                      ? 0
                                      : int.parse(initialActiveController.text),
                                  'initial_suspected': int.tryParse(
                                              initialSuspectedController
                                                  .text) ==
                                          null
                                      ? 0
                                      : int.parse(
                                          initialSuspectedController.text),
                                  'initial_recovery': int.tryParse(
                                              initialRecoveryController.text) ==
                                          null
                                      ? 0
                                      : int.parse(
                                          initialRecoveryController.text),
                                  'initial_death': int.tryParse(
                                              initialDeathController.text) ==
                                          null
                                      ? 0
                                      : int.parse(initialDeathController.text),
                                  "created_at": DateTime.now()
                                };
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
                                              CasesInfoManager()
                                                  .addNewBaranggay(
                                                      data.BaranggayName,
                                                      newData);

                                              Navigator.of(context).push(
                                                  MaterialPageRoute(builder:
                                                      (BuildContext context) {
                                                return Home(
                                                  current_page:
                                                      'Covid-19 Cases',
                                                );
                                              }));
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Saved Successfully!"),
                                                    actions: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("OK"))
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.green,
                                            ),
                                            label: const Text("Publish")),
                                        ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
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
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Update"),
                              )),
                          Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: ElevatedButton(
                                style: ButtonStyle(backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withOpacity(0.5);
                                  }
                                  return Theme.of(context).colorScheme.error;
                                })),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Cancel"),
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ));
  }

  Widget LogDialog(BuildContext dialogContext, CasesRecord data) {
    return Dialog(
      child: StreamBuilder(
        stream: GetLogs(data.BaranggayName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;
            return Container(
              margin: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: const Text("LOGS")),
                      ...data.map((e) {
                        var dateLog = (e['date'] as Timestamp).toDate();
                        return Text(
                          '${e['log']} - $dateLog ',
                          textAlign: TextAlign.left,
                        );
                      }).toList()
                    ]),
              ),
            );
          } else {
            return const Text("Loading Log");
          }
        },
      ),
    );
  }

  Future<List<Cases>> getCases() async {
    List<Cases> result = [];

    final cases =
        await FirebaseFirestore.instance.collection('CovidCases').get();

    for (var element in cases.docs) {
      result.add(Cases.fromJson(element.data(), element.id));
    }

    debugPrint(result.toString());

    setState(() {
      searchVisible = true;
    });

    return result;
  }

  Stream<List<dynamic>> GetLogs(String baranggay) {
    return FirebaseFirestore.instance
        .collection('BaranggayCases')
        .doc(baranggay)
        .collection('Logs')
        .snapshots()
        .map((event) => event.docs);
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
