// ignore_for_file: non_ant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class BaseRecordRepository<T> {
  late String _collectionString = "";
  late List<T> results = <T>[];

  @protected
  set collectionString(String value) => {_collectionString = value};

  Future<QuerySnapshot<Map<String, dynamic>>> get Collection async {
    return await GetCollection();
  }

  CollectionReference get CollectionReferenceData {
    return FirebaseFirestore.instance.collection(_collectionString);
  }

  DocumentReference<Map<String, dynamic>> GetSingleCollection(String id) {
    return FirebaseFirestore.instance.collection(_collectionString).doc(id);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> GetCollection() async {
    final result =
        await FirebaseFirestore.instance.collection(_collectionString).get();
    return result;
  }

  // void MapToResults(Map<String,dynamic> data)
  // {
  //   data.map((key, value) => null)
  // }

  Future<QuerySnapshot<Map<String, dynamic>>> GetSubCollection(
      String path) async {
    final result = await FirebaseFirestore.instance
        .collection('$_collectionString/$path')
        .get();
    return result;
  }

  Future<void> SetSubCollection(
      DocumentReference ref, Map<String, dynamic> data) async {
    return ref.set(data, SetOptions(merge: true));
  }
}
