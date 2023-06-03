// ignore_for_file: prefer__ructors, avoid_unnecessary_containers, prefer__literals_to_create_immutables, deprecated_member_use, import_of_legacy_library_into_null_safe, must_be_immutable, body_might_complete_normally_nullable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/main.dart';
import 'package:infodash_app/pages/casespage.dart';
import 'package:infodash_app/pages/homepage.dart';
import 'package:infodash_app/pages/reportedcasepage.dart';
import 'package:infodash_app/pages/swabcenterpage.dart';
import 'package:infodash_app/pages/vaccinatedpage.dart';
import 'package:infodash_app/pages/vaccinationhubpage.dart';
import 'package:infodash_app/pages/variantpage.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:badges/badges.dart' as badges;

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);
final Color avatarColor =
    Colors.primaries[Random().nextInt(Colors.primaries.length)];

class Home extends StatefulWidget {
  Home({super.key, this.current_page = "Home"});
  String current_page;
  @override
  MyWidgetState createState() => MyWidgetState(current_page);
}

class MyWidgetState extends State<Home> with SingleTickerProviderStateMixin {
  MyWidgetState(this.current_page);
  String current_page;
  final colors = <Color>[Colors.indigo, Colors.blue, Colors.orange, Colors.red];
  double _size = 300.0;

  bool _large = true;

  late dynamic isAdmin = false;
  String userId = "";
  late String userEmail = "USER";
  var hasUnreadNotification = false;

  String fullname = "";

  late Size screen_size;

  @override
  void initState() {
    // TODO: implement initState
    FlutterSession().get("_id").then((value) => setState(() {
          userId = value;
        }));
    super.initState();
    FlutterSession().get('_isAdmin').then((value) => setState(() {
          isAdmin = value;
        }));

    FlutterSession().get("_userEmail").then((value) => setState(() {
          userEmail = value;
        }));
    FlutterSession().get("_fullName").then((value) => setState(() {
          if (value == null) {
            fullname = "";
          } else {
            fullname = value;
          }
        }));
  }

  void _updateSize() {
    setState(() {
      _size = _large ? _size : 0.0;
      _large = !_large;
    });
  }

  void updateNotificationBadge(bool value) {
    setState(() {
      hasUnreadNotification = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    screen_size = MediaQuery.of(context).size;

    if (!_large) {
      if (_size != 0.0) {
        _size = 0.0;
      }
    } else {
      _size = 200;
    }

    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: screen_size.width,
          child: Row(
            children: [
              Container(
                  child: AnimatedSize(
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 500),
                      child: LeftDrawer(
                        size: _size,
                        parent: this,
                      ))),
              Expanded(
                flex: 4,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: ClipRect(
                          child: Expanded(
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.menu,
                                      color: Colors.black87),
                                  onPressed: () {
                                    // _size = screen_size.width / 2;
                                    _updateSize();
                                  },
                                ),
                                Text("Welcome Back $fullname!"),
                                const Spacer(),
                                StreamBuilder<List<dynamic>>(
                                    stream: GetNotificationData(userId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        var data = snapshot.data!;

                                        for (var element in data) {
                                          bool isRead = element['read'] as bool;
                                          if (!isRead) {
                                            hasUnreadNotification = true;
                                          }
                                        }
                                        return badges.Badge(
                                          ignorePointer: false,
                                          showBadge: hasUnreadNotification,
                                          badgeContent: const Text(''),
                                          position:
                                              badges.BadgePosition.topStart(
                                                  start: 8),
                                          child: PopupMenuButton(
                                            onSelected: (value) {
                                              showDialog(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return NotificationDialog(
                                                      dialogContext, value);
                                                },
                                              );
                                            },
                                            tooltip: "Show Notifications",
                                            position: PopupMenuPosition.under,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                        .circular(20)
                                                    .copyWith(
                                                        topRight: const Radius
                                                            .circular(0))),
                                            icon:
                                                const Icon(Icons.notifications),
                                            elevation: 10,
                                            color: Colors.grey.shade300,
                                            itemBuilder: (context) {
                                              if (data.isEmpty) {
                                                return [
                                                  const PopupMenuItem(
                                                      child: Text(
                                                          "No Notifications"))
                                                ].toList();
                                              }

                                              data.sort((a, b) {
                                                return (b['date_sent']
                                                        as Timestamp)
                                                    .toDate()
                                                    .compareTo((a['date_sent']
                                                            as Timestamp)
                                                        .toDate());
                                              });
                                              data.sort((a, b) {
                                                if (b['read'] == false) {
                                                  return 1;
                                                }
                                                return -1;
                                              });
                                              return data.map((e) {
                                                // if (e['read'] as bool == false) {
                                                //   setState(() {
                                                //     hasUnreadNotification = true;
                                                //   });
                                                // }
                                                return NotificationCard(
                                                    context, e);
                                              }).toList();

                                              // return [
                                              //   PopupMenuItem(
                                              //       value: "Notifications",
                                              //       child: SizedBox(
                                              //           width: MediaQuery.of(context)
                                              //                   .size
                                              //                   .width /
                                              //               1,
                                              //           child: Card(
                                              //               child: Text(
                                              //                   "Sample Notification"))))
                                              // ];
                                            },
                                          ),
                                        );
                                      } else {
                                        return const Text(
                                            "Loading Notification");
                                      }
                                    }),
                                CircleAvatar(
                                  backgroundColor: avatarColor,
                                  child: Text(userEmail[0].toUpperCase()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Colors.black12,
                      ),
                      SingleChildScrollView(
                        child: getPage(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem NotificationCard(BuildContext context, dynamic data) {
    late String notificationDate = "";
    String dateDiff = "0";
    String unit = "Hours";
    var outputFormat = DateFormat('MMMM dd, yyyy');
    if (data['date_sent'] != null) {
      DateTime date = (data['date_sent'] as Timestamp).toDate();
      dateDiff = DateTime.now().difference(date).inHours.toString();
      if (int.parse(dateDiff) < 1) {
        dateDiff = DateTime.now().difference(date).inMinutes.toString();
        if (int.parse(dateDiff) < 2 && int.parse(dateDiff) > 0) {
          unit = "Minute";
        } else if (int.parse(dateDiff) < 0) {
          dateDiff = "0";
          unit = "Minute";
        } else {
          unit = "Minutes";
        }
      } else if (int.parse(dateDiff) > 24) {
        dateDiff = DateTime.now().difference(date).inDays.toString();
        if (int.parse(dateDiff) < 2) {
          unit = "Day";
        } else {
          unit = "Days";
        }
      } else if (int.parse(dateDiff) == 1) {
        unit = "Hour";
      } else if (int.parse(dateDiff) < 0) {
        dateDiff = "0";
      }
      // notificationDate = outputFormat.format(date);
    }
    return PopupMenuItem(
        onTap: () {},
        value: data,
        child: SizedBox(
            width: MediaQuery.of(context).size.width / 1,
            child: Card(
                elevation: 0,
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        '${data['sent_by']} sent a notification',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '$dateDiff $unit Ago',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          Visibility(
                              visible: !data['read'],
                              child: const Icon(
                                size: 12,
                                Icons.circle,
                                color: Colors.blueAccent,
                              ))
                        ],
                      )
                    ],
                  ),
                ))));
  }

  Widget NotificationDialog(BuildContext parentContext, dynamic data) {
    var outputFormat = DateFormat('MMMM dd, yyyy hh:mm a');
    late String notificationDate = "";
    if (data['date_sent'] != null) {
      DateTime date = (data['date_sent'] as Timestamp).toDate();
      notificationDate = 'at ${outputFormat.format(date)}';
    }
    SetNotificationRead(data);
    hasUnreadNotification = false;
    return Dialog(
      elevation: 10,
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                      child: Text("${data['title']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18))),
                  Center(
                    child: Text("${data['sent_by']} $notificationDate"),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: MediaQuery.of(parentContext).size.height / 4,
                    width: MediaQuery.of(parentContext).size.width / 3,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text("${data['body']}"),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(parentContext);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Ok'),
                          )),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget? getPage() {
    String currentPage = current_page;
    switch (currentPage) {
      case "Home":
        {
          return const HomePage(title: 'Home');
        }
      case "Covid-19 Cases":
        {
          return CasesPage(title: currentPage);
        }
      case 'Vaccinated People':
        {
          return VaccinatedPage(title: currentPage);
        }
      case 'Available Vaccination Hub':
        {
          return VaccinationHubPage(title: currentPage);
        }
      case 'Available Swab Center':
        {
          return SwabCenterPage(title: currentPage);
        }
      case 'Reported Cases':
        {
          return ReportedCasePage(title: currentPage);
        }
      case 'Report SARS-COV2 Variant':
        {
          return VariantPage(title: currentPage);
        }
      // case 'Sent Notification':
      //   {}
    }
  }

  // String currentPage = current_page;
  void pageChange(page) {
    if (page == 'Send Notification') {
      showDialog(
          context: context,
          builder: (dialogContext) {
            return SendNotificationDialog(context);
          });
    } else {
      setState(() {
        current_page = page;
      });
    }
  }

  Stream<List<dynamic>>? GetNotificationData(String id) {
    if (id != '') {
      var collection =
          FirebaseFirestore.instance.collection('UserAccounts').doc(id);
      var doc = collection.collection('Notification').snapshots();
      var data = doc.map((event) => event.docs);
      return data;
    } else {
      return null;
    }
  }

  void SetNotificationRead(dynamic notificationData) {
    var doc = FirebaseFirestore.instance
        .collection('UserAccounts')
        .doc(userId)
        .collection('Notification')
        .doc(notificationData.id);
    doc.update({'read': true});
  }

  Widget SendNotificationDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController bodyController = TextEditingController();
    return Dialog(
      child: SizedBox(
          child: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 15),
                child: const Text(
                  "Send Notification",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(child: Text("Title:")),
                  Flexible(
                      flex: 5,
                      child: Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: TextFormField(
                            controller: titleController,
                          )))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(child: Text("Body:")),
                    Flexible(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          controller: bodyController,
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, right: 10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          SendNotification(
                              titleController.text, bodyController.text);

                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    "Notification Sent Successfully!"),
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
                          child: Text("Send Notification"),
                        )),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return Home(
                                current_page: current_page,
                              );
                            }));
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
          ],
        ),
      )),
    );
  }

  void SendNotification(String title, String body) {
    var notificationData = {
      'title': title,
      'body': body,
      'date_sent': DateTime.now(),
      'read': false,
      'sent_by': userEmail
    };

    var doc = FirebaseFirestore.instance.collection('UserAccounts');

    doc.snapshots().forEach((element) {
      for (var e in element.docs) {
        var notification = doc.doc(e.id).collection('Notification').doc();
        notification.set(notificationData);
      }
    });
  }
}

class LeftDrawer extends StatefulWidget {
  LeftDrawer({super.key, this.size, required this.parent});

  final double? size;
  final MyWidgetState parent;
  var currentPage = "Home";

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  late dynamic isAdmin = false;
  late String userId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterSession().get('_isAdmin').then((value) => setState(() {
          isAdmin = value;
        }));
    FlutterSession().get("_Id").then((value) => setState(() {
          userId = value;
        }));
  }

  late Size screen_size;
  @override
  Widget build(BuildContext context) {
    // screen_size = MediaQuery.of(context).size;
    // if (screen_size.width < 500) {
    //   if (!_large) {
    //     if (_size != 0.0) {
    //       _size = 0.0;
    //       _large = true;
    //     }
    //   } else {
    //     _size = screen_size.width;
    //   }
    // } else {
    //   _size = screen_size.width / 5;
    // }

    return Container(
        width: widget.size,
        color: Colors.yellow[400],
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Colors.purple,
                    Colors.amber,
                  ])),
              child: Text(
                'INFODASH',
                style: TextStyle(
                    letterSpacing: 1.5,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: Colors.grey,
                          offset: Offset.fromDirection(7, 2))
                    ]),
              ),
            ),
            ...Tiles(),
          ],
        ));
  }

  List<Widget> Tiles() {
    List<Widget> result = List.empty(growable: true);
    result.add(_tile('Home', context));
    result.add(_tile('Covid-19 Cases', context));
    result.add(_tile('Vaccinated People', context));
    result.add(_tile('Available Vaccination Hub', context));
    result.add(_tile('Available Swab Center', context));
    result.add(_tile('Reported Cases', context));
    result.add(_tile('Report SARS-COV2 Variant', context));
    if (isAdmin) {
      result.add(_tile('Send Notification', context));
    }
    result.add(_tile('Logout', context));
    return result.toList();
  }

  String currentPage = "Home";

  Widget _tile(String label, BuildContext context) {
    bool isActive = currentPage == label ? true : false;
    bool isHovering = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return ListTile(
          title: InkWell(
            onTap: () {
              debugPrint(label);
              widget.parent.pageChange(label);
              setState(() {
                currentPage = label;
              });
              switch (label) {
                case "Logout":
                  {
                    FlutterSession().set("_id", "").whenComplete(() =>
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyApp())));
                    break;
                  }
              }
            },
            onHover: (hovering) {
              setState(() => isHovering = hovering);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.ease,
              padding: EdgeInsets.all(isHovering ? 15 : 14.5),
              decoration: BoxDecoration(
                color: HoverBackColor(isActive, isHovering),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                label,
                style: TextStyle(color: activeColor(isActive)),
              ),
            ),
          ),
          onTap: () {
            debugPrint(label);
            widget.parent.pageChange(label);
            setState(() {
              currentPage = label;
            });
            switch (label) {
              case "Logout":
                {
                  FlutterSession().set("_id", "").whenComplete(() =>
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp())));
                  break;
                }
            }
          },
        );
      },
    );
  }

  Color? HoverBackColor(bool isActive, bool isHovering) {
    if (isActive) {
      return Colors.amber[700];
    }

    if (isHovering) {
      return Colors.amber[700];
    } else {
      return Colors.transparent;
    }
  }

  Color? activeColor(isActive) {
    if (isActive) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
