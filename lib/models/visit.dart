import 'package:cloud_firestore/cloud_firestore.dart';

class Visit {
  String id = '';
  String uid = '';
  String cid = '';
  String name = '';
  String description = '';
  double cost = 0;
  Timestamp createdAt;

  Visit(this.uid);

  Visit.fromJson(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        uid = snapshot['uid'],
        cid = snapshot['cid'],
        name = snapshot['name'],
        description = snapshot['description'],
        cost = snapshot['cost'].toDouble(),
        createdAt = snapshot['created_at'];

  Map<String, dynamic> toJson() =>
      {
        'uid': uid,
        'cid': cid,
        'name': name,
        'cost': cost,
        'description': description,
        'created_at': Timestamp.now()
      };

  Map<String, dynamic> toJsonShort() =>
      {
        'name': name,
        'cost': cost,
        'description': description,
        'created_at': createdAt.toDate()
      };
}