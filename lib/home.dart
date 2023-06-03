// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, deprecated_member_use, import_of_legacy_library_into_null_safe, must_be_immutable, body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/main.dart';
import 'package:infodash_app/pages/casespage.dart';
import 'package:infodash_app/pages/homepage.dart';
import 'package:infodash_app/pages/notificationpage.dart';
import 'package:infodash_app/pages/reportedcasepage.dart';
import 'package:infodash_app/pages/swabcenterpage.dart';
import 'package:infodash_app/pages/vaccinatedpage.dart';
import 'package:infodash_app/pages/vaccinationhubpage.dart';
import 'package:infodash_app/pages/variantpage.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  MyWidgetState createState() => MyWidgetState();
}

class MyWidgetState extends State<Home> with SingleTickerProviderStateMixin {
  final colors = <Color>[Colors.indigo, Colors.blue, Colors.orange, Colors.red];
  double _size = 250.0;

  bool _large = true;

  void _updateSize() {
    setState(() {
      _size = _large ? 250.0 : 0.0;
      _large = !_large;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
              //flex: 1,
              child: AnimatedSize(
                  curve: Curves.easeIn,
                  duration: Duration(milliseconds: 500),
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
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.black87),
                          onPressed: () {
                            _updateSize();
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.brightness_3, color: Colors.black87),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.notification_important,
                              color: Colors.black87),
                          onPressed: () {},
                        ),
                        CircleAvatar(),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.black12,
                  ),
                  Container(
                    child: getPage(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? getPage() {
    switch (currentPage) {
      case "Home":
        {
          return HomePage(title: 'Home');
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
      case 'Sent Notification':
        {
          return NotificationPage(title: currentPage);
        }
    }
  }

  String currentPage = "Home";
  void pageChange(page) {
    setState(() {
      currentPage = page;
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
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.size,
        color: Colors.black38,
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              color: Colors.white70,
              child: Text('MENU'),
            ),
            _tile(Icon(Icons.home), 'Home', context),
            _tile(Icon(Icons.sick), 'Covid-19 Cases', context),
            _tile(Icon(Icons.people_alt_rounded), 'Vaccinated People', context),
            _tile(Icon(Icons.local_hospital_rounded),
                'Available Vaccination Hub', context),
            _tile(Icon(Icons.house_rounded), 'Available Swab Center', context),
            _tile(Icon(Icons.person_add_disabled), 'Reported Cases', context),
            _tile(Icon(Icons.report_gmailerrorred), 'Report SARS-COV2 Variant',
                context),
            _tile(Icon(Icons.notification_add_rounded), 'Sent Notification',
                context),
            _tile(Icon(Icons.logout), 'Logout', context),
          ],
        ));
  }

  String currentPage = "Home";

  Widget _tile(icons, String label, BuildContext context) {
    bool isActive = currentPage == label ? true : false;
    return ListTile(
      leading: icons,
      title: Text(
        label,
        style: TextStyle(color: activeColor(isActive)),
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
              FlutterSession().set("_id", "").whenComplete(() => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp())));
              break;
            }
        }
      },
    );
  }

  Color? activeColor(isActive) {
    if (isActive) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
