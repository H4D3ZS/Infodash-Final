// ignore_for_file: non_ant_identifier_names, unnecessary_getters_setters, file_names, unused_field, unused_import
import 'package:infodash_app/infodashlib/Cases/CasesInfoManager.dart';

import 'CaseStatus.dart';

class CasesInfo {
  late String _baranggayName;
  late String _uid;
  late String _reportedBy;
  String? _verifiedBy;
  late DateTime _dateReported;
  DateTime? _dateVerified;
  late int _statusId = CaseStatus.suspected.index;

  late String _year;
  late String _month;

  late String _concern = "";

  String get concern => _concern;

  set concern(String concern) {
    _concern = concern;
  }

  String get BaranggayName {
    return _baranggayName;
  }

  set BaranggayName(String value) {
    _baranggayName = value;
  }

  String get UID {
    return _uid;
  }

  set UID(String value) {
    _uid = value;
  }

  String get ReportedBy {
    return _reportedBy;
  }

  set ReportedBy(String value) {
    _reportedBy = value;
  }

  String? get VerifiedBy => _verifiedBy;
  set VerifiedBy(String? value) {
    _verifiedBy = value;
  }

  DateTime get DateReported => _dateReported;
  set DateReported(DateTime value) {
    _dateReported = value;
  }

  DateTime? get DateVerified => _dateVerified;
  set DateVerified(DateTime? value) {
    _dateVerified = value;
  }

  set StatusId(int? value) {
    if (value != null) {
      _statusId = value;
    }
  }

  CaseStatus get Status =>
      CaseStatus.values.where((element) => element.index == _statusId).first;

  String get Year {
    return _year;
  }

  set Year(String value) {
    _year = value;
  }

  String get Month {
    return _month;
  }

  set Month(String value) {
    _month = value;
  }
}

class CasesRecord {
  late String _baranggayName;
  late List<CasesInfo> _casesInfo = <CasesInfo>[];
  int _deathCount = 0;
  int _recoveryCount = 0;
  int _activeCaseCount = 0;
  int _suspectedCaseCount = 0;

  String? _marking = 'safe';

  int get DeathCount {
    return _deathCount;
  }

  set DeathCount(int? value) {
    value ??= 0;
    _deathCount = value;
  }

  int get RecoveryCount {
    return _recoveryCount;
  }

  set RecoveryCount(int? value) {
    value ??= 0;
    _recoveryCount = value;
  }

  int get ActiveCaseCount {
    return _activeCaseCount;
  }

  set ActiveCaseCount(int? value) {
    value ??= 0;
    _activeCaseCount = value;
  }

  int get SuspectedCaseCount {
    return _suspectedCaseCount;
  }

  set SuspectedCaseCount(int? value) {
    value ??= 0;
    _suspectedCaseCount = value;
  }

  int get TotalCount {
    return DeathCount + RecoveryCount + ActiveCaseCount + SuspectedCaseCount;
  }

  String? get Marking {
    var result = "safe";
    var actives =
        CaseInfo.where((element) => element._statusId == CaseStatus.active)
                .length +
            ActiveCaseCount;
    if (actives >= 20) {
      result = "unsafe";
    } else {
      result = "safe";
    }

    return result;
  }

  set Marking(String? value) {
    if (value != null) {
      _marking = value;
    }
  }

  String get BaranggayName => _baranggayName;
  set BaranggayName(String value) {
    _baranggayName = value;
  }

  List<CasesInfo> get CaseInfo => _casesInfo;
  set CaseInfo(List<CasesInfo> value) {
    _casesInfo = value;
  }
}
