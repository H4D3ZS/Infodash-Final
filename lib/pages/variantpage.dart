// ignore_for_file: no_logic_in_create_state, prefer__ructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/infodashlib/Variants/VariantsInfo.dart';
import 'package:infodash_app/infodashlib/Variants/VariantsRepository.dart';
import 'package:intl/intl.dart';
import 'package:infodash_app/home.dart';

class VariantPage extends StatefulWidget {
  const VariantPage({super.key, required this.title});
  final String title;

  @override
  State<VariantPage> createState() => _VariantPageState(title);
}

class _VariantPageState extends State<VariantPage> {
  _VariantPageState(this.title);
  final String title;
  late Future<List<VariantsInfo>> variants;

  //Controllers
  var reportedDateController = TextEditingController();
  late bool isUserAdmin = false;

  @override
  void initState() {
    super.initState();
    FlutterSession().get("_isAdmin").then((value) {
      if (value != null) {
        isUserAdmin = value;
      }
    });
    variants = VariantsRepository().GetRecords();
  }

  @override
  void dispose() {
    super.dispose();
    reportedDateController.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  ScrollController horizontalScroll = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Flex(
        direction: Axis.vertical,
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
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 200,
              child: SingleChildScrollView(child: Content()))
        ],
      ),
    );
  }

  Widget Content() {
    VariantsInfo variantData = new VariantsInfo();
    return Container(
      margin: const EdgeInsets.all(8),
      child: Center(
          child: Flex(
        direction: Axis.vertical,
        // ignore: prefer__literals_to_create_immutables
        children: [
          const Text(
            "REPORTED SAR-COV2 VARIANTS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          FutureBuilder(
            future: FlutterSession().get("_isAdmin"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Visibility(
                  visible: snapshot.data as bool,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      AddVariant(context, variantData);
                    },
                    label: const Text('Add New Variant'),
                    icon: const Icon(Icons.post_add_rounded),
                    backgroundColor: Colors.cyanAccent.shade700,
                  ),
                );
              } else {
                return const Text("");
              }
            },
          ),
          SizedBox(
            child: FutureBuilder<List<VariantsInfo>>(
                future: variants,
                builder: (contentContext, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      child: Scrollbar(
                        controller: horizontalScroll,
                        child: SingleChildScrollView(
                          controller: horizontalScroll,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              // ignore: prefer__literals_to_create_immutables
                              columns: <DataColumn>[
                                const DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'WHO LABEL',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'PANGO LINEAGE',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'FIRST DETECTED',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'DATE REPORTED',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Visibility(
                                    visible: isUserAdmin,
                                    child: const Expanded(
                                      child: Text(
                                        'OPTIONS',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              rows: List<DataRow>.from(snapshot.data!.map((e) =>
                                  DataRow(cells: [
                                    DataCell(TextButton(
                                        child: Text(e.name),
                                        onPressed: () {
                                          showDialog(
                                            context: contentContext,
                                            builder: (dialogContext) {
                                              return VariantDialog(
                                                  e, dialogContext);
                                            },
                                          );
                                        })),
                                    DataCell(Text(e.lineage)),
                                    DataCell(Text(e.firstDetected)),
                                    DataCell(TextDate(e)),
                                    DataCell(Visibility(
                                      visible: isUserAdmin,
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                AddVariant(contentContext, e);
                                              },
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.yellow)),
                                          IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return SizedBox(
                                                        child: AlertDialog(
                                                      title: const Text(
                                                          "Save Changes?"),
                                                      actionsAlignment:
                                                          MainAxisAlignment.end,
                                                      actions: [
                                                        ElevatedButton.icon(
                                                            onPressed: () {
                                                              RemoveVariant(e);
                                                              Navigator.of(
                                                                      context)
                                                                  .push(new MaterialPageRoute(builder:
                                                                      (BuildContext
                                                                          context) {
                                                                return new Home(
                                                                  current_page:
                                                                      'Report SARS-COV2 Variant',
                                                                );
                                                              }));
                                                            },
                                                            icon: const Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            label: const Text(
                                                                "Yes")),
                                                        ElevatedButton.icon(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: const Icon(
                                                              Icons.cancel,
                                                              color: Colors.red,
                                                            ),
                                                            label: const Text(
                                                                "Cancel"))
                                                      ],
                                                    ));
                                                  },
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ))
                                        ],
                                      ),
                                    ))
                                  ])))),
                        ),
                      ),
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
        ],
      )),
    );
  }

  Future<dynamic> AddVariant(BuildContext parentContext, VariantsInfo data) {
    late TextEditingController nameController =
        new TextEditingController(text: data.name);
    TextEditingController lineageController =
        new TextEditingController(text: data.lineage);
    TextEditingController firstDetectedCountryController =
        new TextEditingController(text: data.firstDetected);
    late DateTime detectedDate = data.dateReported;
    var outputFormat = DateFormat('MMMM dd, yyyy');
    reportedDateController.text = outputFormat.format(data.dateReported);
    TextEditingController descriptionController =
        new TextEditingController(text: data.description);

    return showDialog(
        context: parentContext,
        builder: (context) {
          var symptomsValue = TextEditingController();
          return StatefulBuilder(builder: (context, setState) {
            late List<String> symptoms = <String>[];
            symptoms = data.symptomps;
            void callback(List<String> newValue) {
              setState(() {
                symptoms = newValue;
              });
            }

            return Dialog(
              elevation: 16,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                  width: MediaQuery.of(parentContext).size.width / 3,
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      child: Flex(
                        direction: Axis.vertical,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text(
                              "Add New Variant",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextFormField(
                            controller: nameController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "Enter Variant Name",
                                labelText: "Variant Name",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: lineageController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "Enter Lineage",
                                labelText: "Lineage",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: firstDetectedCountryController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "Enter First Detected Country",
                                labelText: "First Detected County",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            textAlign: TextAlign.center,
                            readOnly: true,
                            controller: reportedDateController,
                            onTap: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2019),
                                      lastDate: DateTime.now())
                                  .then((value) {
                                if (value != null) {
                                  var outputFormat =
                                      DateFormat('MMMM dd, yyyy');
                                  var valueFormmated =
                                      outputFormat.format(value);
                                  detectedDate = value;
                                  reportedDateController.text =
                                      valueFormmated.toString();
                                }
                              });
                            },
                            decoration: const InputDecoration(
                                hintText: "Enter First Detected Date",
                                labelText: "First Detected Date",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          TextFormField(
                            controller: descriptionController,
                            keyboardType: TextInputType.multiline,
                            minLines: 2,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                hintText: "Enter Description",
                                labelText: "Description",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: const Text(
                              "Symptoms",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(parentContext)
                                            .size
                                            .width /
                                        5,
                                    child: TextFormField(
                                      controller: symptomsValue,
                                      decoration: const InputDecoration(
                                          hintText: "Enter Symptom"),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        if (symptomsValue.text != "") {
                                          symptoms.add(symptomsValue.text);
                                          symptomsValue.text = "";
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(parentContext).size.height / 4,
                            child: ListView.builder(
                              itemBuilder: (context, position) {
                                return SymptomsCard(position, symptoms,
                                    callback: callback);
                              },
                              itemCount: symptoms.length,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      VariantsInfo newVarient =
                                          new VariantsInfo();
                                      newVarient.name = nameController.text;
                                      newVarient.lineage =
                                          lineageController.text;
                                      newVarient.firstDetected =
                                          firstDetectedCountryController.text;
                                      newVarient.dateReported = detectedDate;
                                      newVarient.description =
                                          descriptionController.text;
                                      newVarient.symptomps = symptoms;
                                      SaveVariant(newVarient);
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return new Home(
                                          current_page:
                                              'Report SARS-COV2 Variant',
                                        );
                                      }));
                                    },
                                    child: const Text("Save")),
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return new Home(
                                          current_page:
                                              'Report SARS-COV2 Variant',
                                        );
                                      }));
                                    },
                                    child: const Text("Cancel"))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
            );
          });
        });
  }

  Widget SymptomsCard(int position, List<String> symptomsList,
      {required callback}) {
    return StatefulBuilder(builder: (context, setState) {
      var symptomValue = symptomsList[position];
      if (position % 2 == 0) {
        return Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '- $symptomValue',
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      symptomsList.remove(symptomValue);
                      callback(symptomsList);
                    });
                  },
                  icon: const Icon(Icons.remove))
            ],
          ),
        );
      } else {
        return Card(
          color: Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  '- $symptomValue',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      symptomsList.remove(symptomValue);
                      callback(symptomsList);
                    });
                  },
                  icon: const Icon(Icons.remove))
            ],
          ),
        );
      }
    });
  }

  Widget TextDate(VariantsInfo e) {
    var outputFormat = DateFormat('MMMM dd, yyyy');
    var dateFormatted = outputFormat.format(e.dateReported);
    return Text(dateFormatted.toString());
  }

  Widget VariantDialog(VariantsInfo e, BuildContext parent) {
    return Dialog(
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: MediaQuery.of(parent).size.width / 2,
        child: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(20),
              child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Image.network(
                      e.imageUrl,
                      scale: 0.5,
                      width: MediaQuery.of(parent).size.width / 2 - 50,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(border: Border.all(width: 1)),
                      child: SizedBox(
                          width: MediaQuery.of(parent).size.width / 2,
                          child: const Center(
                              child: Text(
                            "GENERAL DETAILS",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )))),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Text(
                              "VARIANT NAME",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Text(
                          e.name.toUpperCase(),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Text(
                              "LINEAGE",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Text(
                          e.lineage.toUpperCase(),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Text(
                              "FIRST DETECTED AT",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Text(
                          e.firstDetected.toUpperCase(),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Text(
                              "DATE REPORTED",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        TextDate(e),
                      ],
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(border: Border.all(width: 1)),
                      child: SizedBox(
                          width: MediaQuery.of(parent).size.width / 2,
                          child: const Center(
                              child: Text(
                            "VARIANT DESCRIPTION",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )))),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          e.description,
                          style: const TextStyle(
                              wordSpacing: 5,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(border: Border.all(width: 1)),
                      child: SizedBox(
                          width: MediaQuery.of(parent).size.width / 2,
                          child: const Center(
                              child: Text(
                            "SYMPTOMS",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )))),
                  Center(
                    child: Flex(
                        direction: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: e.symptomps
                            .map((e) => Text(
                                  e.toString(),
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600),
                                ))
                            .toList()),
                  )
                ],
              )),
        ),
      ),
    );
  }

  void SaveVariant(VariantsInfo data) {
    VariantsRepository().SaveRecord(data);
  }

  void RemoveVariant(VariantsInfo data) {
    VariantsRepository().RemoveRecord(data);
  }
}
