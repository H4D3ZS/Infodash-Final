// ignore_for_file: no_logic_in_create_state, unnecessary_new, non_ant_identifier_names, prefer__literals_to_create_immutables, unnecessary_string_interpolations, prefer__ructors

import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
// import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationHubPage extends StatefulWidget {
  const VaccinationHubPage({super.key, required this.title});
  final String title;
  @override
  State<VaccinationHubPage> createState() => _VaccinationHubPageState(title);
}

class _VaccinationHubPageState extends State<VaccinationHubPage> {
  final collectionPath = 'VaccinationHub';

  _VaccinationHubPageState(this.title);
  final String title;
  late String keyword = "";
  TextEditingController search = new TextEditingController();
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height-400,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.black),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              keyword = search.text;
                            });
                          },
                          controller: search,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                              hintText: "SEARCH VACCINATION HUB",
                              // labelText: "SUSPECTED CASE",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always),
                        ),
                      ),
                      // IconButton(
                      //     onPressed: () {

                      //     },
                      //     icon: Icon(Icons.search))
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(top: 20),
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
                                    builder: (dlcontext) {
                                      var dialogContext = dlcontext;
                                      return VaccinationHubDialog(
                                          dialogContext);
                                    });
                              },
                              icon: const Icon(
                                // <-- Icon
                                Icons.add_box_rounded,
                                size: 24.0,
                              ),
                              label: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Add Vaccination Hub'),
                              ), // <-- Text
                            ),
                          ),
                        ),
                      ),
                    )),
                StreamBuilder<List<dynamic>>(
                    stream: GetVaccinationHubs(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final hubs = snapshot.data!;
                        return SizedBox(
                          height: MediaQuery.of(context).size.height - 250,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: hubs.map((e) {
                                if (keyword == "") {
                                  return HubCard(e);
                                }
                                if (e['name']
                                    .toString()
                                    .toUpperCase()
                                    .contains(keyword.toUpperCase())) {
                                  return HubCard(e);
                                }
                                return const Text("");
                              }).toList(),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const AlertDialog(content: Text("Error Getting Data"));
                      } else {
                        return const CircularProgressIndicator(
                          backgroundColor: Colors.redAccent,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                          strokeWidth: 10,
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget HubCard(dynamic data) {
    String mapLink = data['map_link'];
    String name = data['name'];
    String description = data['description'];
    String id = data['id'];
    return Container(
      margin: const EdgeInsets.all(5),
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.green[100],
          elevation: 10,
          child: GestureDetector(
            onTap: () => {launchUrlString(mapLink)},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.vaccines, size: 60),
                    title: Tooltip(
                      textAlign: TextAlign.start,
                      message: "Open Vaccination Direction On Google Maps",
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text('$name', style: const TextStyle(fontSize: 20.0)),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$description', style: const TextStyle(fontSize: 18.0)),
                        Visibility(
                          visible: isUserAdmin,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () => {
                                        showDialog(
                                            context: context,
                                            builder: (dlcontext) {
                                              var dialogContext = dlcontext;
                                              return VaccinationHubDialog(
                                                  dialogContext,
                                                  isNew: false,
                                                  data: data);
                                            })
                                      },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.yellow[900],
                                  )),
                              IconButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('VaccinationHub')
                                        .doc(id)
                                        .delete();
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  )),
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
    );
  }

  Widget VaccinationHubDialog(BuildContext parent,
      {bool isNew = true, dynamic data}) {
    late TextEditingController nameController = new TextEditingController();
    late TextEditingController detailsController = new TextEditingController();
    late TextEditingController mapLinkController = new TextEditingController();
    var dialogTitle = isNew ? 'NEW VACCINATION HUB' : 'MODIFY VACCINATION HUB';
    if (!isNew) {
      nameController.text = data['name'];
      detailsController.text = data['description'];
      mapLinkController.text = data['map_link'];
    }

    return new Dialog(
        elevation: 16,
        child: SizedBox(
            // height: MediaQuery.of(parent).size.height / 2,
            width: MediaQuery.of(parent).size.width / 2,
            child: SingleChildScrollView(
                child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '$dialogTitle',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextFormField(
                        controller: nameController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            hintText: "ENTER VACCINATION HUB NAME",
                            labelText: "HUB NAME",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      TextFormField(
                        maxLines: 3,
                        controller: detailsController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            // hintText: "ENTER VACCINATION HUB DETAILS",
                            labelText: "HUB DETAILS",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      TextFormField(
                        controller: mapLinkController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            hintText: "ENTER VACCINATION HUB MAP LINK",
                            labelText: "GOOGLE MAP LINK",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              child: OutlinedButton(
                                  onPressed: () {
                                    if (isNew) {
                                      CreateVaccinationHub(
                                              name: nameController.text,
                                              description:
                                                  detailsController.text,
                                              map_link: mapLinkController.text)
                                          .then(
                                              (value) => Navigator.pop(parent))
                                          .onError((error, stackTrace) =>
                                              const AlertDialog(
                                                  content:
                                                      Text("ERROR SAVING")));
                                    } else {
                                      final json = {
                                        'name': nameController.text,
                                        'description': detailsController.text,
                                        'map_link': mapLinkController.text,
                                        'id': data['id'].toString()
                                        // 'id': data['id'],
                                      };
                                      UpdateVaccinationHub(
                                              id: data['id'], data: json)
                                          .then(
                                              (value) => Navigator.pop(parent))
                                          .onError((error, stackTrace) =>
                                              const AlertDialog(
                                                  content:
                                                      Text("ERROR SAVING")));
                                    }
                                  },
                                  child: const Text("Save")),
                            ),
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

  Future CreateVaccinationHub(
      {required name, String description = '', String map_link = ''}) async {
    final docVaccinationHub =
        FirebaseFirestore.instance.collection(collectionPath).doc();

    final json = {
      'id': docVaccinationHub.id,
      'name': name,
      'description': description,
      'map_link': map_link
    };
    await docVaccinationHub.set(json);
  }

  Future UpdateVaccinationHub({required id, dynamic data}) async {
    final hub = FirebaseFirestore.instance.collection(collectionPath).doc(id);

    await hub.set(data, SetOptions(merge: true));
  }

  Stream<List<dynamic>> GetVaccinationHubs() {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());
  }
}
