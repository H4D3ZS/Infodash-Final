// ignore: file_names
// ignore_for_file: unnecessary_new, unused_import

//import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/infodashlib/Cases/CaseStatus.dart';
import 'package:infodash_app/infodashlib/Cases/CasesInfo.dart';
import 'package:infodash_app/infodashlib/Common/BaseRecordRepository.dart';
import 'package:infodash_app/infodashlib/Common/Month.dart';

class CasesInfoRepository extends BaseRecordRepository<CasesRecord> {
  CasesInfoRepository() {
    collectionString = "BaranggayCases";
  }

  Future<List<CasesRecord>> GetRecords() async {
    List<CasesRecord> result = <CasesRecord>[];

    final cases = await Collection;
    for (var elements in cases.docs) {
      var baranggay = elements.id;
      CasesRecord currentRecord = CasesRecord();
      var info = <CasesInfo>[];
      currentRecord.BaranggayName = baranggay;
      final initialData = elements.data();
      currentRecord.ActiveCaseCount = initialData['initial_active'];
      currentRecord.SuspectedCaseCount = initialData['initial_suspected'];
      currentRecord.RecoveryCount = initialData['initial_recovery'];
      currentRecord.DeathCount = initialData['initial_death'];
      currentRecord.Marking = initialData['marking'];
      final caseRecord = await GetSubCollection("$baranggay/Cases");
      for (var record in caseRecord.docs) {
        var data = new CasesInfo();
        // data.ActiveCaseCount = int.tryParse(initial_value[''].toString());

        data.BaranggayName = elements.id;
        data.UID = record.id;
        var field = record.data();
        data.DateReported = (field['date_reported'] as Timestamp).toDate();
        data.StatusId = field['status_id'];
        data.concern = field['concern'];
        if (field['date_verified'] != null) {
          data.DateVerified = (field['date_verified'] as Timestamp).toDate();
        }
        data.ReportedBy = field['reported_by'];
        info.add(data);
      }
      currentRecord.CaseInfo = info;
      result.add(currentRecord);

      // var elementData = caseRecord.id();
      // data.DeathCount = elementData!['death'];
      // data.RecoveryCount = elementData['recovery'];
      // data.ActiveCaseCount = elementData['cases'];
      // debugPrint(data.DeathCount.toString());
      // debugPrint(data.RecoveryCount.toString());
      // debugPrint(data.ActiveCaseCount.toString());

    }

    results = result;

    return results;
  }

  Future<void> UpdateBaranggayMarking(String baranggay, String marking) async {
    UpdateLog(baranggay, "Changed Marking To $marking");
    await CollectionReferenceData.doc(baranggay).update({'marking': marking});
  }

  void UpdateLog(String baranggay, String log) {
    CollectionReferenceData.doc(baranggay)
        .collection('Logs')
        .doc()
        .set({'log': log, 'date': DateTime.now()});
  }

  Future<void> SaveBaranggayRecord(
      String baranggay, CaseStatus status, int count) async {
    final data = await GetSingleCollection(baranggay).get();
    switch (status) {
      case CaseStatus.active:
        {
          int active = data['initial_active'];
          UpdateLog(baranggay, "Added Active: $count");
          await CollectionReferenceData.doc(baranggay)
              .update({'initial_active': active + count});
        }
        break;
      case CaseStatus.suspected:
        int active = data['initial_suspected'];
        UpdateLog(baranggay, "Added Suspected: $count");
        await CollectionReferenceData.doc(baranggay)
            .update({'initial_suspected': active + count});
        break;
      case CaseStatus.recovered:
        int active = data['initial_recovery'];
        UpdateLog(baranggay, "Added Recovered: $count");
        await CollectionReferenceData.doc(baranggay)
            .update({'initial_recovery': active + count});
        break;
      case CaseStatus.death:
        int active = data['initial_death'];
        UpdateLog(baranggay, "Added Death: $count");
        await CollectionReferenceData.doc(baranggay)
            .update({'initial_death': active + count});
        break;
    }
  }

  Future<void> SaveCaseRecord(String baranggay, CaseStatus status,
      String concern, dynamic detailsData) async {
    var userEmail = await FlutterSession().get("_userEmail");
    Map<String, dynamic> data = {
      "status_id": status.index,
      "date_reported": DateTime.now(),
      // "date_verified": DateTime.now(),
      "reported_by": userEmail,
      // "verified_by": userEmail,
      "concern": concern,
      "step": 0
    };
    data.addAll(detailsData);
    //CollectionReferenceData.doc(baranggay).set({}, SetOptions(merge: true));

    DocumentReference doc = CollectionReferenceData.doc(baranggay);
    // final baranggayData = await Collection;
    // final fields = baranggayData.docs
    //     .where((element) => element.id.toUpperCase() == baranggay.toUpperCase())
    //     .first;
    // final initial_data = {"initial_active": fields['initial_active']};
    // if (_status == CaseStatus.active) {
    //   int active = fields['inital_active'];
    //   if (active != null) {
    //     doc.update({"initial_active": active + 1});
    //   }
    // }

    CollectionReference ref = doc.collection('Cases');
    doc.update({"created_at": DateTime.now()});
    DocumentReference cases = ref.doc();
    results = [];
    cases.collection("Conversation").doc().set({
      'message':
          'Thank you for reporting. Please wait while we validate your report. Stay Safe!',
      'sent': DateTime.now(),
      'sender': 'admin@infodash.com'
    });
    return SetSubCollection(cases, data);
  }

  Future<List<String>> GetBaranggays() async {
    List<String> result = <String>[];
    final cases = await Collection;
    for (var elements in cases.docs) {
      result.add(elements.id);
    }
    return result;
  }

  Future<void> SaveInitialData(String baranggay, dynamic data) async {
    DocumentReference doc = CollectionReferenceData.doc(baranggay);
    doc.set(data);
    UpdateLog(baranggay, "Updates Initial Data $baranggay");
    if (data['initial_active'] >= 20) {
      UpdateBaranggayMarking(baranggay, "Unsafe");
    } else {
      UpdateBaranggayMarking(baranggay, "Safe");
    }
    results = [];
  }
}
