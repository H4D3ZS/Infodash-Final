// ignore_for_file: avoid_web_libraries_in_flutter, avoid_function_literals_in_foreach_calls, unused_local_variable, import_of_legacy_library_into_null_safe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_session/flutter_session.dart';

class User {
  final String id;
  final String email;
  final String password;
  final String userType;
  final String fullName;
  User(this.id, this.email, this.password, this.userType, this.fullName);

  String _age = "";

  String get age => _age;

  set age(String age) {
    _age = age;
  }

  String _address = "";

  String get address => _address;

  set address(String address) {
    _address = address;
  }

  String _gender = "";

  String get gender => _gender;

  set gender(String gender) {
    _gender = gender;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'userType': userType,
        'age': age,
        'address': address,
        'gender': gender
      };

  static User fromJson(Map<String, dynamic> json) => User(json['id'],
      json['email'], json['password'], json['userType'], json['name']);

  Future<User> login() async {
    User loggedInUser = this;
    final users = await FirebaseFirestore.instance
        .collection('UserAccounts')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    users.docs.forEach((element) {
      User data = fromJson(element.data());
      loggedInUser = data;
    });

    if (loggedInUser.id != "") {
      await FlutterSession().set("_id", loggedInUser.id);
      await FlutterSession().set("_userEmail", loggedInUser.email);
      await FlutterSession().set("_fullName", loggedInUser.fullName);
      bool isAdmin = false;
      if (loggedInUser.userType.toUpperCase() == "ADMIN") {
        isAdmin = true;
      }

      await FlutterSession().set("_isAdmin", isAdmin);
    }

    // ignore: prefer__declarations
    return loggedInUser;
  }

  Future<String> register() async {
    final docUser = FirebaseFirestore.instance.collection('UserAccounts').doc();
    final user = User(docUser.id, email, password, userType, fullName);
    await docUser.set(user.toJson());
    return id;
  }
}
