import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // CREATE
  Future addStaffDetails(Map<String, dynamic> staffInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Staff")
        .add(staffInfoMap); // Use random doc ID
  }

  // READ
  Stream<QuerySnapshot> getStaffDetails() {
    return FirebaseFirestore.instance.collection("Staff").snapshots();
  }

  // UPDATE
  Future updateStaffDetail(String docId, Map<String, dynamic> updateInfo) async {
    return await FirebaseFirestore.instance
        .collection("Staff")
        .doc(docId)
        .update(updateInfo);
  }

  // DELETE
  Future deleteStaffDetail(String docId) async {
    return await FirebaseFirestore.instance
        .collection("Staff")
        .doc(docId)
        .delete();
  }
}