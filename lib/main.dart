// ignore_for_file: unused_import, unrelated_type_equality_checks, import_of_legacy_library_into_null_safe, prefer__ructors, avoid_unnecessary_containers
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/home.dart';
import 'package:infodash_app/login2.dart';
import 'firebase_options.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InfoDash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: bodyData(context),
      builder: (BuildContext contex, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container(
              child: Scaffold(
                  body: Center(
            child: LoadingAnimationWidget.waveDots(
              color: Colors.white,
              size: 200,
            ),
          )));
        }
        final Widget page = snapshot.data;
        return page;
      });

  Future<StatefulWidget> bodyData(context) {
    return FlutterSession().get("_id").then((value) {
      if (value != "" && value != null) {
        return Home(
          current_page: '',
        );
      } else {
        return LoginPage();
      }
    });
  }
}
