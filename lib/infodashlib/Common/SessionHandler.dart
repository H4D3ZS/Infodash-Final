// ignore: file_names
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_session/flutter_session.dart';

class SessionHandler {
  Future<bool> isAdmin() async {
    bool result = await FlutterSession().get('_isAdmin') as bool;

    return result;
  }
}
