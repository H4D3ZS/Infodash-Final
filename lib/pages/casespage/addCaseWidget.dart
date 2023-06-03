// ignore_for_file: prefer__literals_to_create_immutables, prefer__ructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infodash_app/home.dart';
import 'package:infodash_app/infodashlib/Cases/CaseStatus.dart';
import 'package:infodash_app/infodashlib/Cases/CasesInfoManager.dart';

class AddCase extends StatefulWidget {
  final Future<List<String>> baranggays;
  final VoidCallback notifyParent;
  const AddCase({super.key, required this.baranggays, required this.notifyParent});
  @override
  State<AddCase> createState() => _AddCaseState();
}

class _AddCaseState extends State<AddCase> {
  late Future<List<String>> baranggayList;
  var cases = <CaseStatus>[];
  var selectedStatus = CaseStatus.suspected;
  late String selectedValue = "";
  var manager = CasesInfoManager();
  late TextEditingController baranggayController = TextEditingController();
  late TextEditingController initialActiveController = TextEditingController();
  late TextEditingController initialSuspectedController =
      TextEditingController();
  late TextEditingController initialRecoveryController =
      TextEditingController();
  late TextEditingController initialDeathController = TextEditingController();
  late Future<List<String>> baranggays;

  Future<List<String>> getBaranggayList() {
    return CasesInfoManager().GetBaranggayList();
  }

  late Widget addCase;

  @override
  void initState() {
    super.initState();
    cases = CaseStatus.values.toList();
    baranggays = widget.baranggays;
  }

  @override
  void dispose() {
    super.dispose();
    baranggayController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BuildContext dialogContext;
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (bcontext) {
                    dialogContext = context;
                    return AddCaseDialog(context);
                  });
            },
            icon: const Icon(
              // <-- Icon
              Icons.add_box_rounded,
              size: 24.0,
            ),
            label: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Add New Case'),
            ), // <-- Text
          ),
        ),
      ),
    );
  }

  Widget AddCaseDialog(BuildContext parent) {
    bool isNewBaranggay = false;
    bool isValid = false;
    TextEditingController CaseCountController = new TextEditingController();
    return new Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 16,
        child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 2,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
                alignment: Alignment.center,
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Center(
                          child: Text(
                            "Add New Case",
                            style: TextStyle(
                                fontSize: 26.0,
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Roboto"),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: const Text(
                                    "Subdivision :",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                        fontFamily: "Roboto"),
                                  ),
                                ),
                                Expanded(child: BaranggayList(baranggays)),
                                IconButton(
                                  tooltip: "Add New Subdivision",
                                  icon: const Icon(Icons.add_circle),
                                  onPressed: (() {
                                    showDialog(
                                        context: parent,
                                        builder: (dialogContext) {
                                          return Dialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40)),
                                              elevation: 16,
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    1.5,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Container(
                                                    margin: const EdgeInsets.only(
                                                        left: 10, right: 10),
                                                    child: Container(
                                                      margin: const EdgeInsets.all(8),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            const Text(
                                                              "Enter New Subdivision",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      26.0,
                                                                  color: Color(
                                                                      0xFF000000),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      "Roboto"),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                              dialogContext)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  10,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    baranggayController,
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .always,
                                                                validator:
                                                                    (val) {
                                                                  if (val ==
                                                                          "" ||
                                                                      val ==
                                                                          null ||
                                                                      val.isEmpty) {
                                                                    isValid =
                                                                        false;
                                                                    return "Invalid Subdivision Name";
                                                                  } else {
                                                                    isValid =
                                                                        true;
                                                                    return null;
                                                                  }
                                                                },
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                decoration: const InputDecoration(
                                                                    hintText:
                                                                        "ENTER SUBDIVISION NAME",
                                                                    labelText:
                                                                        "Subdivision",
                                                                    floatingLabelBehavior:
                                                                        FloatingLabelBehavior
                                                                            .always),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                              dialogContext)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  10,
                                                              child:
                                                                  TextFormField(
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'[0-9]'))
                                                                ],
                                                                controller:
                                                                    initialActiveController,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                decoration: const InputDecoration(
                                                                    hintText:
                                                                        "ENTER ACTIVE CASE INITIAL VALUE",
                                                                    labelText:
                                                                        "ACTIVE CASE",
                                                                    floatingLabelBehavior:
                                                                        FloatingLabelBehavior
                                                                            .always),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                              dialogContext)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  10,
                                                              child:
                                                                  TextFormField(
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'[0-9]'))
                                                                ],
                                                                controller:
                                                                    initialSuspectedController,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                decoration: const InputDecoration(
                                                                    hintText:
                                                                        "ENTER SUSPECTED CASE INITIAL VALUE",
                                                                    labelText:
                                                                        "SUSPECTED CASE",
                                                                    floatingLabelBehavior:
                                                                        FloatingLabelBehavior
                                                                            .always),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                              dialogContext)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  10,
                                                              child:
                                                                  TextFormField(
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'[0-9]'))
                                                                ],
                                                                controller:
                                                                    initialRecoveryController,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                decoration: const InputDecoration(
                                                                    hintText:
                                                                        "ENTER RECOVERY CASE INITIAL VALUE",
                                                                    labelText:
                                                                        "RECOVERY CASE",
                                                                    floatingLabelBehavior:
                                                                        FloatingLabelBehavior
                                                                            .always),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                              dialogContext)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  10,
                                                              child:
                                                                  TextFormField(
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'[0-9]'))
                                                                ],
                                                                controller:
                                                                    initialDeathController,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                decoration: const InputDecoration(
                                                                    hintText:
                                                                        "ENTER DEATH CASE INITIAL VALUE",
                                                                    labelText:
                                                                        "DEATH CASE",
                                                                    floatingLabelBehavior:
                                                                        FloatingLabelBehavior
                                                                            .always),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: const EdgeInsets
                                                                  .only(
                                                                      top: 20),
                                                              child: Flex(
                                                                direction: Axis
                                                                    .horizontal,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        final data =
                                                                            {
                                                                          'mark_status':
                                                                              'safe',
                                                                          'initial_active': int.tryParse(initialActiveController.text) == null
                                                                              ? 0
                                                                              : int.parse(initialActiveController.text),
                                                                          'initial_suspected': int.tryParse(initialSuspectedController.text) == null
                                                                              ? 0
                                                                              : int.parse(initialSuspectedController.text),
                                                                          'intial_recovery': int.tryParse(initialRecoveryController.text) == null
                                                                              ? 0
                                                                              : int.parse(initialRecoveryController.text),
                                                                          'initial_death': int.tryParse(initialDeathController.text) == null
                                                                              ? 0
                                                                              : int.parse(initialDeathController.text),
                                                                          "created_at":
                                                                              DateTime.now()
                                                                        };

                                                                        if (isValid) {
                                                                          setState(
                                                                              () {
                                                                            CasesInfoManager().addNewBaranggay(baranggayController.text,
                                                                                data);
                                                                          });
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return AlertDialog(
                                                                                title: const Text("Saved Successfully!"),
                                                                                actions: [
                                                                                  ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: const Text("OK"))
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                          Navigator.of(context).push(new MaterialPageRoute(builder:
                                                                              (BuildContext context) {
                                                                            return new Home(
                                                                              current_page: 'Covid-19 Cases',
                                                                            );
                                                                          }));
                                                                        }
                                                                      },
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.all(8.0),
                                                                        child: Text(
                                                                            "Add"),
                                                                      )),
                                                                  Container(
                                                                    margin: const EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                    child: ElevatedButton(
                                                                        style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                                                          if (states
                                                                              .contains(MaterialState.pressed)) {
                                                                            return Theme.of(context).colorScheme.error.withOpacity(0.5);
                                                                          }
                                                                          return Theme.of(context)
                                                                              .colorScheme
                                                                              .error;
                                                                        })),
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                              dialogContext);
                                                                        },
                                                                        child: const Padding(
                                                                          padding:
                                                                              EdgeInsets.all(8.0),
                                                                          child:
                                                                              Text("Cancel"),
                                                                        )),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              ));
                                        });
                                  }),
                                  iconSize: 21.0,
                                  color: const Color(0xFF000000),
                                )
                              ]),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(15, 0, 25, 0),
                          child: Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  child: const Text(
                                    "Status: ",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Color(0xFF000000),
                                        fontWeight: FontWeight.w200,
                                        fontFamily: "Roboto"),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButtonFormField(
                                      isExpanded: true,
                                      style: const TextStyle(
                                          fontSize: 17.0,
                                          color: Color(0xFF202020),
                                          fontWeight: FontWeight.w200,
                                          fontFamily: "Roboto"),
                                      items: cases.map((e) {
                                        return DropdownMenuItem<CaseStatus>(
                                            value: cases
                                                .where(
                                                    (element) => element == e)
                                                .first,
                                            child: Text(e.name));
                                      }).toList(),
                                      value: selectedStatus,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatus = value!;
                                        });
                                      },
                                      onSaved: (e) {
                                        setState(() {
                                          selectedStatus = e!;
                                        });
                                      }),
                                ),
                              ]),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(15, 0, 25, 0),
                          child: TextFormField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            controller: CaseCountController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "ENTER NEW CASE COUNT",
                                labelText: "NEW CASE COUNT",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 20, 5, 0),
                          child: SizedBox(
                            child: Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      CasesInfoManager().SaveBaranggayCases(
                                          selectedValue,
                                          selectedStatus,
                                          int.parse(CaseCountController.text));

                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return new Home(
                                          current_page: 'Covid-19 Cases',
                                        );
                                      }));
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Saved Successfully!"),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("OK"))
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Add"),
                                    )),
                                Container(
                                  margin: const EdgeInsets.only(left: 10, right: 10),
                                  child: ElevatedButton(
                                      style: ButtonStyle(backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .error
                                              .withOpacity(0.5);
                                        }
                                        return Theme.of(context)
                                            .colorScheme
                                            .error;
                                      })),
                                      onPressed: () {
                                        Navigator.pop(parent);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Cancel"),
                                      )),
                                )
                              ],
                            ),
                          ),
                        )
                      ]),
                ),
              ),
            )));
  }

  Widget BaranggayList(Future<List<String>> list) {
    return FutureBuilder<List<String>>(
        future: list,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              selectedValue = snapshot.data!
                  .firstWhere((element) => true, orElse: () => '');
              return Container(
                child: DropdownButtonFormField(
                    isExpanded: true,
                    style: const TextStyle(
                        fontSize: 17.0,
                        color: Color(0xFF202020),
                        fontWeight: FontWeight.w200,
                        fontFamily: "Roboto"),
                    value: selectedValue,
                    items: snapshot.data!
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onSaved: (e) {
                      setState(() {
                        selectedValue = e.toString();
                      });
                    },
                    onChanged: (e) {
                      setState(() {
                        selectedValue = e.toString();
                      });
                    }),
              );
            } else if (snapshot.hasError) {
              return const Text("Add New Subdivision");
            }
          }

          return const LinearProgressIndicator(
            backgroundColor: Colors.redAccent,
            valueColor: AlwaysStoppedAnimation(Colors.green),
          );
        });
  }
}
