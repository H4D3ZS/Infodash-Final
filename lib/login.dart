// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infodash_app/home.dart';
import 'infodashlib/users.dart';

// void main() => runApp(MyApp());

// ignore: use_key_in_widget_constructors
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loginFail = false;
  bool isValid = false;
  String errorText = "";
  bool showSpinner = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.amber[200],
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text('Login To InfoDash',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              ),
            ),
            Visibility(
              visible: loginFail,
              child: Container(
                  margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Card(
                        elevation: 50,
                        color: Colors.red[300],
                        child: Container(
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10, bottom: 10),
                            child: Text(errorText)),
                      ))),
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) {
                        String email = val!;
                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(email);
                        if (!emailValid) {
                          isValid = false;
                          return 'Invalid Email Address';
                        } else {
                          isValid = true;
                          return null;
                        }
                      },
                      controller: emailController,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      )),
                )),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: 5),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                        value == "" ? "Please Input Valid Password" : null,
                    controller: passwordController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                )),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.4, 50),
                  backgroundColor: Colors.purple[200],
                  foregroundColor: Colors.white,
                ),
                icon: Icon(Icons.lock_open, size: 32),
                label: Text('Sign In', style: TextStyle(fontSize: 24)),
                onPressed: () {
                  if (emailController.text != "" &&
                      passwordController.text != "" &&
                      isValid) {
                    signIn();
                  } else {
                    setState(() {
                      loginFail = true;
                      errorText = "Please Input Valid Email or Password";
                    });
                  }
                },
              ),
            ),
          ],
        ),
      )));

  signIn() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              CircularProgressIndicator(),
              Text("Loading"),
            ],
          ),
        );
      },
    );
    User newUser =
        User('', emailController.text, passwordController.text, 'user');
    newUser.login().then(((value) {
      if (value.id != '') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        setState(() {
          loginFail = true;
          errorText = "Invalid Email or Password";
        });

        Navigator.of(context).pop();
        debugPrint('Closed');
      }
    }));
  }
}
