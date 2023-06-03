// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infodash_app/home.dart';
import 'infodashlib/users.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/img/loginimg.png"),
                    fit: BoxFit.cover),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "INFODASH",
                      style:
                          TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(
                                  1,
                                  1,
                                ),
                                color: Colors.grey.withOpacity(0.2))
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          TextInputType.emailAddress;
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
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 7,
                              offset: Offset(
                                1,
                                1,
                              ),
                              color: Colors.grey.withOpacity(0.2))
                        ]),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value == "" ? "Please Input Valid Password" : null,
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.password),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70,
            ),
            GestureDetector(
              onTap: () {
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
              child: Container(
                width: w * 0.5,
                height: h * 0.08,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                      image: AssetImage("assets/img/loginbtn.png"),
                      fit: BoxFit.cover),
                ),
                child: Center(
                  child: Text(
                    "Sign In ",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: w * 0.10,
            ),
            RichText(
              text: TextSpan(
                  text: "Don\'t have an account?",
                  style: TextStyle(color: Colors.grey[500], fontSize: 20),
                  children: [
                    TextSpan(
                        text: "Create",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                        // ..onTap = () => Get.to(
                        //       () => SignUpPage(),
                        //     ),
                        ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

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
