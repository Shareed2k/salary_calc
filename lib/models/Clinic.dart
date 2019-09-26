import 'package:cloud_firestore/cloud_firestore.dart';

class Clinic {
  String id = '';
  String uid;
  String name = '';
  String description = '';
  double doctorProcent = 0;
  Timestamp createdAt;

  Clinic(this.uid);

  Clinic.fromJson(DocumentSnapshot snapshot)
    : id = snapshot.documentID,
      uid = snapshot['uid'],
      name = snapshot['name'],
      description = snapshot['description'],
      doctorProcent = snapshot['doctor_procent'].toDouble(),
      createdAt = snapshot['created_at'];

  Map<String, dynamic> toJson() =>
    {
      'uid': uid,
      'name': name,
      'doctor_procent': doctorProcent,
      'description': description,
      'created_at': Timestamp.now()
    };
}