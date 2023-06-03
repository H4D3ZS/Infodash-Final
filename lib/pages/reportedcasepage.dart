// ignore_for_file: no_logic_in_create_state, unnecessary_new, prefer__ructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:infodash_app/infodashlib/Cases/CaseStatus.dart';
import 'package:infodash_app/infodashlib/Cases/CasesInfoManager.dart';
import 'package:flutter_session/flutter_session.dart';

class ReportedCasePage extends StatefulWidget {
  ReportedCasePage({super.key, required this.title});
  final String title;
  @override
  State<ReportedCasePage> createState() => _ReportedCasePageState(title);
}

class _ReportedCasePageState extends State<ReportedCasePage> {
  _ReportedCasePageState(this.title);
  final String title;

  late dynamic isAdmin;
  late String email;
  @override
  void initState() {
    super.initState();
    FlutterSession().get('_isAdmin').then((value) => isAdmin = value);
    FlutterSession().get("_userEmail").then((value) => email = value);
  }

  int unprocessed = 0;
  int processing = 0;
  int processed = 0;

  addProcessCounts(int status, int count) {
    setState(
      () {
        switch (status) {
          case 1:
            unprocessed += count;
            break;
          case 2:
            processing += count;
            break;
          case 3:
            processed += count;
            break;
          default:
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BuildContext mainContext = context;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Card(
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
            ),
            // Center(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Card(
            //         child: Text("Unprocessed: ${unprocessed} "),
            //       ),
            //       Card(
            //         child: Text("Processing: ${processing}"),
            //       ),
            //       Card(
            //         child: Text("Processed: ${processed}"),
            //       ),
            //     ],
            //   ),
            // ),
            StreamBuilder<List<dynamic>>(
                stream: GetReportedCases(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    // List<dynamic> data = new List.empty(growable: true);
                    // baranggay.forEach((item) {
                    //   var baranggayData = FirebaseFirestore.instance
                    //       .collection('BaranggayCases')
                    //       .doc(item.id)
                    //       .snapshots();

                    //   baranggayData.forEach((element) {
                    //     data.add(element);
                    //   });
                    // });
                    if (data.length <= 0) {
                      return Text("No Record Found");
                    }

                    var finalData = data.map((e) {
                      var baranggayList = FirebaseFirestore.instance
                          .collection('BaranggayCases')
                          .doc(e.id)
                          .collection('Cases')
                          .orderBy('date_reported', descending: true)
                          .snapshots();

                      var baranggayData = baranggayList.map((event) {
                        // event.docs.sort((a, b) {
                        //   var aData = (a['date_reported'] as Timestamp)
                        //       .toDate()
                        //       .toUtc();
                        //   var bData = (b['date_reported'] as Timestamp)
                        //       .toDate()
                        //       .toUtc();
                        //   return bData.compareTo(aData);
                        // });
                        // event.docs.sort((a, b) {
                        //   return (a['date_reported'] as Timestamp)
                        //       .compareTo(
                        //           (b['date_reported'] as Timestamp));
                        // });

                        // unprocessed = event.docs
                        //     .where((e) =>
                        //         e['process_status'] == null ||
                        //         e['process_status'] == 'unprocessed')
                        //     .length;

                        // processing = event.docs
                        //     .where((e) =>
                        //         e['process_status'] == 'processing')
                        //     .length;\s

                        return event.docs;
                      });

                      return {'data': baranggayData, 'parent': e};
                    }).toList();

                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: finalData.map((e) {
                            return ReportCard(
                                e['data'], e['parent'], mainContext);
                          }).toList(),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error Getting Data");
                  } else {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.redAccent,
                      valueColor: AlwaysStoppedAnimation(Colors.green),
                      strokeWidth: 10,
                    );
                  }
                }),
            FutureBuilder(
              future: FlutterSession().get('_isAdmin'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  isAdmin = snapshot.data as bool;
                  return Visibility(
                    visible: snapshot.data as bool == false,
                    child: Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (dlcontext) {
                                        var dialogContext = dlcontext;
                                        return ReportNewCaseDialog(mainContext);
                                      });
                                },
                                icon: Icon(
                                  // <-- Icon
                                  Icons.add_box_rounded,
                                  size: 24.0,
                                ),
                                label: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Report New Case'),
                                ), // <-- Text
                              ),
                            ),
                          ),
                        )),
                  );
                } else {
                  return Text("Loading");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget ReportCard(Stream<List<dynamic>> dataList, dynamic parent,
      BuildContext parentContext) {
    return StreamBuilder<List<dynamic>>(
        stream: dataList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;
            var finalData = data
                .where((element) {
                  if (isAdmin) {
                    return true;
                  } else {
                    if (email.toString().toUpperCase() ==
                        element['reported_by'].toString().toUpperCase()) {
                      return true;
                    } else {
                      return false;
                    }
                  }
                })
                .map((e) => e)
                .toList();
            finalData.sort((a, b) {
              return (b['date_reported'] as Timestamp)
                  .toDate()
                  .compareTo((a['date_reported'] as Timestamp).toDate());
            });
            return Column(
                children: finalData
                    .map((e) => ReportCardBuilder(e, parent, parentContext))
                    .toList());
          } else {
            return Text("");
          }
        });
  }

  ScrollController scroll = new ScrollController();
  Widget ReportCardBuilder(
      dynamic reportData, dynamic parent, BuildContext parentContext) {
    var reportField = reportData.data();
    reportField['id'] = reportData.id;
    DateTime reportedDate =
        (reportField['date_reported'] as Timestamp).toDate();
    String verified_date = reportField['date_verified'] == null
        ? ""
        : reportField['date_verified'].toString();
    reportField['process_status'] = reportField['process_status'] == null
        ? "unprocessed"
        : reportField['process_status'];
    if (reportField['date_verified'] != null) {
      reportField['process_status'] = "processed";
    }
    // if (reportField['process_status'] == "unprocessed") {
    //   addProcessCounts(1, 1);
    // } else if (reportField['process_status'] == 'processing') {
    //   addProcessCounts(2, 1);
    // } else {
    //   addProcessCounts(3, 1);
    // }
    int currStep =
        reportField['step'] == null ? 0 : (reportField['step'] as int);
    TextEditingController messageController = TextEditingController();
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        margin: EdgeInsets.all(5),
        child: Scrollbar(
          controller: scroll,
          child: SingleChildScrollView(
            controller: scroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.green[100],
                elevation: 10,
                child: GestureDetector(
                  // onTap: () => {launchUrlString(map_link)},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person, size: 60),
                        title: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                              'Reported By: ${reportField['reported_by']}',
                              style: TextStyle(fontSize: 20.0)),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adress: ${parent.id}',
                                style: TextStyle(fontSize: 18.0)),
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                  'Reported Date: ${reportedDate.toString()}',
                                  style: TextStyle(fontSize: 10.0)),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                  '${verified_date == "" ? "PENDING VERIFICATION" : "VERIFIED"}',
                                  style: TextStyle(fontSize: 10.0)),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                  "${reportField['process_status'].toString().toUpperCase()}",
                                  style: TextStyle(fontSize: 10.0)),
                            ),
                            Text(
                                'Concern: ${reportField['concern'] == null ? '-' : reportField['concern']}',
                                style: TextStyle(fontSize: 18.0)),
                            //BUTTONS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                    visible: (reportField['status_id']
                                                as int) ==
                                            1 ||
                                        (reportField['status_id'] as int) == 0,
                                    child: Tooltip(
                                        message: "Show Report Details",
                                        child: IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      ReportDetails(
                                                          reportedCase:
                                                              reportData,
                                                          parent: parent,
                                                          context: context));
                                            },
                                            icon: Icon(Icons.list,
                                                color: Color.fromARGB(
                                                    255, 2, 86, 155))))),
                                Visibility(
                                  visible: isAdmin &&
                                      reportField['process_status'] ==
                                          'unprocessed',
                                  child: Tooltip(
                                    message: "Process Concern",
                                    child: IconButton(
                                        onPressed: () => {
                                              FirebaseFirestore.instance
                                                  .collection('BaranggayCases')
                                                  .doc(parent.id)
                                                  .collection('Cases')
                                                  .doc(reportData.id)
                                                  .update({
                                                'process_status': "processing"
                                              })
                                            },
                                        icon: Icon(
                                          Icons.wifi_protected_setup_sharp,
                                          color: Colors.blue[700],
                                        )),
                                  ),
                                ),
                                Visibility(
                                  visible: isAdmin,
                                  child: Tooltip(
                                    message: verified_date == ""
                                        ? "Click to Verify Report"
                                        : "Click to Unverify Report",
                                    child: IconButton(
                                        onPressed: () {
                                          if (verified_date == "") {
                                            FirebaseFirestore.instance
                                                .collection('BaranggayCases')
                                                .doc(parent.id)
                                                .collection('Cases')
                                                .doc(reportData.id)
                                                .update({
                                              'date_verified': DateTime.now()
                                            });
                                          } else {
                                            FirebaseFirestore.instance
                                                .collection('BaranggayCases')
                                                .doc(parent.id)
                                                .collection('Cases')
                                                .doc(reportData.id)
                                                .update({
                                              'date_verified':
                                                  FieldValue.delete()
                                            });
                                          }
                                        },
                                        icon: verified_date == ""
                                            ? Icon(Icons.remove_moderator,
                                                color: Colors.red)
                                            : Icon(Icons.verified,
                                                color: Colors.green)),
                                  ),
                                ),
                                Visibility(
                                  visible: isAdmin ||
                                      (verified_date == "" && !isAdmin),
                                  child: IconButton(
                                      onPressed: () => {
                                            showDialog(
                                                context: context,
                                                builder: (dlcontext) {
                                                  var dialogContext = dlcontext;
                                                  return UpdateReportCaseDialog(
                                                      dialogContext,
                                                      reportField,
                                                      parent);
                                                })
                                          },
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.yellow[900],
                                      )),
                                ),
                                Visibility(
                                  visible: isAdmin ||
                                      (verified_date == "" && !isAdmin),
                                  child: IconButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('BaranggayCases')
                                            .doc(parent.id)
                                            .collection('Cases')
                                            .doc(reportData.id)
                                            .delete();
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      )),
                                ),
                              ],
                            ),

                            Visibility(
                              visible: (reportField['status_id'] as int) == 1 ||
                                  (reportField['status_id'] as int) == 0,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1,
                                height: MediaQuery.of(context).size.height / 6,
                                child: Stepper(
                                    type: StepperType.horizontal,
                                    controlsBuilder: (context, details) {
                                      return Row(
                                        children: <Widget>[],
                                      );
                                    },
                                    currentStep: currStep,
                                    steps: [
                                      Step(
                                          isActive: currStep >= 0,
                                          state: currStep >= 1
                                              ? StepState.complete
                                              : StepState.disabled,
                                          title: SizedBox.shrink(),
                                          content: SizedBox.shrink()),
                                      Step(
                                          isActive: currStep >= 1,
                                          state: currStep >= 2
                                              ? StepState.complete
                                              : StepState.disabled,
                                          title: SizedBox.shrink(),
                                          content: SizedBox.shrink()),
                                      Step(
                                          isActive: currStep >= 2,
                                          state: currStep >= 3
                                              ? StepState.complete
                                              : StepState.disabled,
                                          title: SizedBox.shrink(),
                                          content: SizedBox.shrink()),
                                      Step(
                                          isActive: currStep >= 3,
                                          state: currStep >= 4
                                              ? StepState.complete
                                              : StepState.disabled,
                                          title: SizedBox.shrink(),
                                          content: SizedBox.shrink()),
                                      Step(
                                          isActive: currStep >= 4,
                                          state: currStep >= 4
                                              ? StepState.complete
                                              : StepState.disabled,
                                          title: SizedBox.shrink(),
                                          content: SizedBox.shrink())
                                    ]),
                              ),
                            ),

                            //CONVERSATION
                            Text("Conversations:"),
                            StreamBuilder<List<dynamic>>(
                                stream: GetConversation(parent, reportData),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var data = snapshot.data!;
                                    data.sort((a, b) {
                                      return (b['sent'] as Timestamp)
                                          .toDate()
                                          .compareTo((a['sent'] as Timestamp)
                                              .toDate());
                                    });
                                    return Container(
                                      padding: EdgeInsets.all(8),
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              8,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: data
                                              .map((e) => Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      '${e['sender']} : ${e['message']}')))
                                              .toList(),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Text("Loading Conversations");
                                  }
                                }),
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 5,
                                    child: TextFormField(
                                      onFieldSubmitted: (value) {
                                        var data = {
                                          'sender': email,
                                          'message': messageController.text,
                                          'sent': DateTime.now()
                                        };
                                        sendMessage(parent, reportData, data);
                                        setState(() {
                                          messageController.text = "";
                                        });
                                      },
                                      controller: messageController,
                                      decoration: InputDecoration(
                                          hintText: "Enter Message"),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        var data = {
                                          'sender': email,
                                          'message': messageController.text,
                                          'sent': DateTime.now()
                                        };
                                        sendMessage(parent, reportData, data);
                                        setState(() {
                                          messageController.text = "";
                                        });
                                      },
                                      icon: Icon(Icons.send))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  String selectedBaranggay = "";
  CaseStatus selectedCaseStatus = CaseStatus.suspected;
  bool isValid = false;
  bool isValidFields = false;
  Widget ReportNewCaseDialog(BuildContext parentContext) {
    TextEditingController concernController = new TextEditingController();
    TextEditingController fullnameController = new TextEditingController();

    TextEditingController addressController = new TextEditingController();
    TextEditingController ageController = new TextEditingController();
    TextEditingController emailController =
        new TextEditingController(text: email);
    TextEditingController mobileController = new TextEditingController();
    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        // height: MediaQuery.of(parentContext).size.height / 2,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                    child: Text("NEW CASE REPORT"),
                  ),
                  StreamBuilder(
                      stream: GetReportedCases(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data!;
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: DropdownButtonFormField(
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) {
                                  if (selectedBaranggay == "") {
                                    return "Please Select Baranggay";
                                  }
                                },
                                hint: Text("Select Baranggay"),
                                items: data
                                    .map((e) => DropdownMenuItem(
                                          value: e.id,
                                          child: Text(e.id),
                                        ))
                                    .toList(),
                                onSaved: (newValue) {
                                  setState(() {
                                    selectedBaranggay = newValue.toString();
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedBaranggay = value.toString();
                                    isValid = true;
                                  });
                                }),
                          );
                        } else {
                          return Text("Loading Baranggay");
                        }
                      }),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButtonFormField(
                        value: selectedCaseStatus,
                        hint: Text("Select Report Status"),
                        items: CaseStatus.values
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ))
                            .toList(),
                        onSaved: (newValue) {
                          setState(() {
                            selectedCaseStatus = newValue!;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedCaseStatus = value!;
                          });
                        }),
                  ),
                  Visibility(
                    visible: selectedCaseStatus == CaseStatus.active ||
                        selectedCaseStatus == CaseStatus.suspected,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Fill up all information below")),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextFormField(
                                  controller: fullnameController,
                                  autovalidateMode: AutovalidateMode.always,
                                  onChanged: (value) {
                                    setState(() {
                                      isValidFields =
                                          fullnameController.text != "" &&
                                              addressController.text != "" &&
                                              ageController.text != "" &&
                                              emailController.text != "" &&
                                              mobileController.text != "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == "") {
                                      return "Required Field";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      labelText: "Full Name",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextFormField(
                                  controller: addressController,
                                  autovalidateMode: AutovalidateMode.always,
                                  onChanged: (value) {
                                    setState(() {
                                      isValidFields =
                                          fullnameController.text != "" &&
                                              addressController.text != "" &&
                                              ageController.text != "" &&
                                              emailController.text != "" &&
                                              mobileController.text != "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == "") {
                                      return "Required Field";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      labelText: "Address",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextFormField(
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLength: 2,
                                  controller: ageController,
                                  autovalidateMode: AutovalidateMode.always,
                                  onChanged: (value) {
                                    setState(() {
                                      isValidFields =
                                          fullnameController.text != "" &&
                                              addressController.text != "" &&
                                              ageController.text != "" &&
                                              emailController.text != "" &&
                                              mobileController.text != "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == "") {
                                      return "Required Field";
                                    }
                                  },
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]'))
                                  ],
                                  decoration: InputDecoration(
                                      labelText: "Age",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextFormField(
                                  controller: emailController,
                                  autovalidateMode: AutovalidateMode.always,
                                  onChanged: (value) {
                                    setState(() {
                                      isValidFields =
                                          fullnameController.text != "" &&
                                              addressController.text != "" &&
                                              ageController.text != "" &&
                                              emailController.text != "" &&
                                              mobileController.text != "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == "") {
                                      return "Required Field";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      labelText: "Email",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextFormField(
                              controller: mobileController,
                              autovalidateMode: AutovalidateMode.always,
                              onChanged: (value) {
                                setState(() {
                                  isValidFields =
                                      fullnameController.text != "" &&
                                          addressController.text != "" &&
                                          ageController.text != "" &&
                                          emailController.text != "" &&
                                          mobileController.text != "";
                                });
                              },
                              validator: (value) {
                                if (value == "") {
                                  return "Required Field";
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: "Mobile #",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      controller: concernController,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                          labelText: "CONCERNS",
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 5),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: isValid && isValidFields,
                            child: OutlinedButton.icon(
                                onPressed: () {
                                  var detailsData = {
                                    "fullname": fullnameController.text,
                                    "address": addressController.text,
                                    "age": int.parse(ageController.text),
                                    "email": emailController.text,
                                    "mobile": mobileController.text,
                                  };
                                  setState(() {
                                    SubmitReportedCase(
                                        selectedBaranggay,
                                        selectedCaseStatus,
                                        concernController.text,
                                        detailsData);
                                    selectedBaranggay = "";
                                    selectedCaseStatus = CaseStatus.suspected;

                                    Navigator.pop(parentContext);
                                  });
                                },
                                icon: Icon(
                                  Icons.send,
                                ),
                                label: Text("SUBMIT REPORT")),
                          ),
                          OutlinedButton.icon(
                            label: Text("Cancel"),
                            onPressed: () {
                              setState(() {
                                selectedBaranggay = "";
                                selectedCaseStatus = CaseStatus.suspected;
                                Navigator.pop(parentContext);
                              });
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red[600],
                            ),
                          )
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
    });
  }

  Widget ReportDetails(
      {dynamic reportedCase,
      dynamic parent,
      BuildContext? context,
      bool enableEdit = false}) {
    int currStep =
        reportedCase['step'] == null ? 0 : (reportedCase['step'] as int);
    TextEditingController fullnameController =
        new TextEditingController(text: reportedCase['fullname']);

    TextEditingController addressController =
        new TextEditingController(text: reportedCase['address']);
    TextEditingController ageController =
        new TextEditingController(text: reportedCase['age'].toString());
    TextEditingController emailController =
        new TextEditingController(text: reportedCase['email']);
    TextEditingController mobileController =
        new TextEditingController(text: reportedCase['mobile']);

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          content: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width / 1.5,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "${enableEdit ? 'Fill up all information below' : 'Reported Case Details'}")),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: TextFormField(
                            enabled: enableEdit,
                            controller: fullnameController,
                            decoration: InputDecoration(
                                labelText: "Full Name",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: TextFormField(
                            enabled: enableEdit,
                            controller: addressController,
                            decoration: InputDecoration(
                                labelText: "Address",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: TextFormField(
                            enabled: enableEdit,
                            controller: ageController,
                            decoration: InputDecoration(
                                labelText: "Age",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: TextFormField(
                            enabled: enableEdit,
                            controller: emailController,
                            decoration: InputDecoration(
                                labelText: "Email",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextFormField(
                        enabled: enableEdit,
                        controller: mobileController,
                        decoration: InputDecoration(
                            labelText: "Mobile #",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text("Process Details"),
                    ),
                    Container(
                      margin: EdgeInsets.all(1),
                      child: Theme(
                        data: Theme.of(context),
                        // ignore: prefer__literals_to_create_immutables
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Stepper(
                              controlsBuilder: (context, details) {
                                return Row(
                                  children: <Widget>[
                                    Visibility(
                                      visible: (currStep < 2 &&
                                              isAdmin as bool == false) ||
                                          (currStep >= 2 &&
                                              currStep < 4 &&
                                              isAdmin as bool == true),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ButtonStyle(),
                                          onPressed: () {
                                            setState(() {
                                              currStep += 1;
                                              var data = {
                                                'step': currStep,
                                                'process_status': 'processing'
                                              };

                                              if (currStep >= 4) {
                                                data['process_status'] =
                                                    'processed';
                                                data.addAll({
                                                  'date_verified':
                                                      DateTime.now()
                                                });
                                              }

                                              updateReportDetails(
                                                  parent, reportedCase, data);
                                            });
                                          },
                                          child: Text('COMPLETE'),
                                        ),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding:  EdgeInsets.all(8.0),
                                    //   child: ElevatedButton(
                                    //     onPressed: () {},
                                    //     child:  Text('CANCEL'),
                                    //   ),
                                    // ),
                                  ],
                                );
                              },
                              currentStep: currStep,
                              steps: [
                                Step(
                                    isActive: currStep >= 0,
                                    state: currStep >= 1
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text("Get Swab Test"),
                                    content: Text(
                                        "Check AVAILABLE SWAB CENTER page to look for Swab Center near you")),
                                Step(
                                    isActive: currStep >= 1,
                                    state: currStep >= 2
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text("Send Swab Test Result "),
                                    content: Text(
                                        "To maintain privacy and confidentiality email us your Swab Test Result at healthcentercatgrande2021@gmail.com")),
                                Step(
                                    isActive: currStep >= 2,
                                    state: currStep >= 3
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title:
                                        Text("Admin is processing your report"),
                                    content: Text(
                                        "Please wait while the admin is trying to process your report, this will take a couple of hours. If this process takes longer than usual you can drop us a message on conversation box")),
                                Step(
                                    isActive: currStep >= 3,
                                    state: currStep >= 4
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text("Admin will contact you"),
                                    content: Text(
                                        "Please expect a phone call or email from our team. Thank you")),
                                Step(
                                    isActive: currStep >= 4,
                                    state: currStep >= 4
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text("DONE"),
                                    content: Text(
                                        "We Appreciate your cooperation. Thank you so much. Stay Safe!"))
                              ]),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Close"),
                ))
          ],
        );
      },
    );
  }

  Widget UpdateReportCaseDialog(
      BuildContext parentContext, dynamic data, dynamic parent) {
    TextEditingController concernController =
        new TextEditingController(text: data['concern']);
    String selectedBaranggay = parent.id;
    bool isValid = true;
    CaseStatus selectedCaseStatus = CaseStatus.values
        .where((element) => element.index == data['status_id'])
        .first;
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        elevation: 16,
        child: SizedBox(
          height: MediaQuery.of(parentContext).size.height / 2,
          width: MediaQuery.of(parentContext).size.width / 2,
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text("NEW CASE REPORT"),
                ),
                StreamBuilder(
                    stream: GetReportedCases(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return DropdownButtonFormField(
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value) {
                              if (selectedBaranggay == "") {
                                return "Please Select Baranggay";
                              }
                            },
                            hint: Text("Select Baranggay"),
                            value: parent.id,
                            items: data
                                .map((e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.id),
                                    ))
                                .toList(),
                            onSaved: (newValue) {
                              setState(() {
                                selectedBaranggay = newValue.toString();
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                selectedBaranggay = value.toString();
                                isValid = true;
                              });
                            });
                      } else {
                        return Text("Loading Baranggay");
                      }
                    }),
                DropdownButtonFormField(
                    value: selectedCaseStatus,
                    hint: Text("Select Report Status"),
                    items: CaseStatus.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            ))
                        .toList(),
                    onSaved: (newValue) {
                      setState(() {
                        selectedCaseStatus = newValue!;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedCaseStatus = value!;
                      });
                    }),
                TextFormField(
                  controller: concernController,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                      labelText: "CONCERNS",
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: isValid,
                        child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                data['concern'] = concernController.text;
                                data['status_id'] = selectedCaseStatus.index;
                                FirebaseFirestore.instance
                                    .collection('BaranggayCases')
                                    .doc(parent.id)
                                    .collection('Cases')
                                    .doc(data['id'])
                                    .update(data);
                                // SubmitReportedCase(selectedBaranggay,
                                //     selectedCaseStatus, concernController.text);
                                // selectedBaranggay = "";
                                // selectedCaseStatus = CaseStatus.suspected;
                                Navigator.pop(context);
                              });
                            },
                            icon: Icon(
                              Icons.send,
                            ),
                            label: Text("UPDATE REPORT")),
                      ),
                      OutlinedButton.icon(
                        label: Text("Cancel"),
                        onPressed: () {
                          setState(() {
                            selectedBaranggay = "";
                            selectedCaseStatus = CaseStatus.suspected;
                            Navigator.pop(context);
                          });
                        },
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red[600],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
        ),
      );
    });
  }

  Stream<List<dynamic>> GetReportedCases() {
    var baranggayList =
        FirebaseFirestore.instance.collection('BaranggayCases').snapshots();
    var baranggayData = baranggayList.map((event) => event.docs);
    return baranggayData;
  }

  Stream<List<dynamic>> GetConversation(dynamic parent, dynamic reportData) {
    return FirebaseFirestore.instance
        .collection('BaranggayCases')
        .doc(parent.id)
        .collection('Cases')
        .doc(reportData.id)
        .collection('Conversation')
        .snapshots()
        .map((event) => event.docs);
  }

  void sendMessage(dynamic parent, dynamic reportData, dynamic data) {
    var doc = FirebaseFirestore.instance
        .collection('BaranggayCases')
        .doc(parent.id)
        .collection('Cases')
        .doc(reportData.id)
        .collection('Conversation')
        .doc();
    doc.set(data);
  }

  void updateReportDetails(dynamic parent, dynamic reportData, dynamic data) {
    var doc = FirebaseFirestore.instance
        .collection('BaranggayCases')
        .doc(parent.id)
        .collection('Cases')
        .doc(reportData.id);
    doc.update(data);
  }

  void SubmitReportedCase(String _baranggay, CaseStatus _status,
      String _concern, dynamic detailsData) {
    CasesInfoManager()
        .SaveCaseRecord(_baranggay, _status, _concern, detailsData);
  }
}
