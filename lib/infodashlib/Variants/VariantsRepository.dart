// ignore_for_file: unused_import, import_of_legacy_library_into_null_safe

// import 'dart:ffi';

// import 'dart:ffi';

import 'package:infodash_app/infodashlib/Common/BaseRecordRepository.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/infodashlib/Variants/VariantsInfo.dart';

class VariantsRepository extends BaseRecordRepository<VariantsInfo> {
  VariantsRepository() {
    collectionString = "Variants";
  }

  Future<List<VariantsInfo>> GetRecords() async {
    if (results.isEmpty) {
      List<VariantsInfo> result = [];
      final cases = await Collection;
      for (var record in cases.docs) {
        VariantsInfo currentRecord = VariantsInfo();
        currentRecord.name = record.id;
        var fields = record.data();

        currentRecord.lineage = fields['lineage'];
        currentRecord.firstDetected = fields['first_detected'];
        currentRecord.description = fields['description'];
        currentRecord.imageUrl = fields['image_url'];
        currentRecord.dateReported =
            (fields['date_reported'] as Timestamp).toDate();
        List<String> sysmptoms = (fields['symptoms'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        currentRecord.symptomps = sysmptoms;

        result.add(currentRecord);
      }
      results = result;
    }
    return results;
  }

  void SaveRecord(VariantsInfo record) {
    var json = record.toJson();
    var doc =
        FirebaseFirestore.instance.collection('Variants').doc(record.name);
    doc.set(json);
  }

  void RemoveRecord(VariantsInfo record) {
    var json = record.toJson();
    var doc =
        FirebaseFirestore.instance.collection('Variants').doc(record.name);
    doc.delete();
  }
}
