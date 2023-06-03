// ignore_for_file: non_ant_identifier_names, no_leading_underscores_for_local_identifiers, unnecessary_null_comparison, avoid_init_to_null, unnecessary_getters_setters, import_of_legacy_library_into_null_safe, unused_import, duplicate_import

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/infodashlib/Cases/CasesInfo.dart';
import 'package:infodash_app/infodashlib/Cases/CasesInfoRepository.dart';
import 'package:infodash_app/infodashlib/Cases/CaseStatus.dart';
import 'CaseStatus.dart';

class CasesInfoManager {
  CasesInfoRepository infoRepository = CasesInfoRepository();
  static final CasesInfoManager _manager = CasesInfoManager._internal();

  factory CasesInfoManager() {
    return _manager;
  }

  CasesInfoManager._internal();

  Future<List<CasesRecord>> GetCasesRecords() async {
    Future<List<CasesRecord>> result = infoRepository.GetRecords();
    return result;
  }

  List<String>? _baranggayList = null;

  List<String>? get baranggayList {
    return _baranggayList;
  }

  set baranggayList(List<String>? value) {
    _baranggayList = value;
  }

  Future<List<String>> GetBaranggayList() async {
    if (baranggayList == null) {
      List<dynamic> _baranggay = await FlutterSession().get('_baranggay');
      _baranggay = [];
      if (_baranggay.isEmpty) {
        baranggayList = await infoRepository.GetBaranggays();
        await FlutterSession().set('_baranggay', jsonEncode(baranggayList));
      } else {
        baranggayList = _baranggay.map((e) => e.toString()).toList();
      }
      debugPrint('Baranggay List $_baranggay'.toString());
    }
    return baranggayList!;
  }

  void addNewBaranggay(String name, dynamic data) {
    // if (_baranggayList!
    //     .where((element) => element.toUpperCase() == name.toUpperCase())
    //     .isEmpty) {
    infoRepository.SaveInitialData(name, data).then((value) {
      if (!_baranggayList!.contains(name)) {
        _baranggayList = null;
      }
    });
    // }
  }

  Future<void> SaveCaseRecord(String baranggay, CaseStatus _status,
      String concern, dynamic detailsData) {
    return infoRepository.SaveCaseRecord(
        baranggay, _status, concern, detailsData);
  }

  Future<void> SaveBaranggayCases(
      String baranggay, CaseStatus _status, int count) {
    return infoRepository.SaveBaranggayRecord(baranggay, _status, count);
  }

  Future<void> UpdateBaranggayMarking(String baranggay, String marking) {
    return infoRepository.UpdateBaranggayMarking(baranggay, marking);
  }

  List<CaseStatus> GetCaseStatus() {
    List<CaseStatus> result = [];
    result.add(CaseStatus.active);
    result.add(CaseStatus.suspected);
    result.add(CaseStatus.recovered);
    result.add(CaseStatus.death);

    return result;
  }
}
