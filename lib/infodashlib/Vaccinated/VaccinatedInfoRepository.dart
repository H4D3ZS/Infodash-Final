import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:infodash_app/infodashlib/Vaccinated/VaccinatedInfo.dart';
import 'package:infodash_app/infodashlib/Common/BaseRecordRepository.dart';

class VaccinatedInfoRepository extends BaseRecordRepository<VaccinatedInfo> {
  VaccinatedInfoRepository() {
    collectionString = 'Vaccinated';
  }

  Future<VaccinatedInfo> GetRecord() async {
    final vaccinatedInfo = await Collection;
    print(vaccinatedInfo);
    return new VaccinatedInfo();
  }
}
