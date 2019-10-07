import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salary_calc/models/clinic.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flushbar/flushbar.dart';
import 'package:validators/validators.dart';

import 'clinic/clinic_row.dart';
import 'clinic_visit_list_page.dart';

class ClinicPage extends StatelessWidget {
  final FirebaseUser user;

  ClinicPage({@required this.user});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();

    return Scaffold(
        backgroundColor: Color(0xFF736AB7),
        appBar: AppBar(
          title: Text('מרפאות'),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add_to_queue,
                color: Colors.white,
              ),
              onPressed: () => _createClinicDialog(context),
            ),
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                _gSignIn.signOut();

                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('clinics')
                  .where('uid', isEqualTo: this.user.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // TODO: create loading with bar
                if (!snapshot.hasData) return Text('Loading...');
                return ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return _setList(context, Clinic.fromJson(document));
                  }).toList(),
                );
              },
            ),
          ))
        ]));
  }

  Widget _setList(BuildContext context, Clinic clinic) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Color(0xFF736AB7),
        child: InkWell(
          child: ClinicRow(clinic),
          onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    VisitListPage(user: this.user, clinic: clinic),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              )),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'מחק',
          color: Color(0xFF736AB7),
          icon: Icons.delete,
          onTap: () => _deleteClinicDialog(context, clinic),
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'ערוך',
          color: Color(0xFF736AB7),
          icon: Icons.edit,
          onTap: () => _createClinicDialog(context, clinic: clinic),
        ),
      ],
    );
  }

  void showInfoFlushbar(BuildContext context, String title, String message) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.error,
        size: 28,
        color: Colors.blue.shade300,
      ),
      leftBarIndicatorColor: Colors.blue.shade300,
      duration: Duration(seconds: 5),
    )..show(context);
  }

  // ignore: avoid_init_to_null
  Future<void> _createClinicDialog(BuildContext context,
      {Clinic clinic = null}) async {
    final _formKey = GlobalKey<FormState>();

    if (clinic == null) clinic = Clinic(this.user.uid);

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title:
                clinic.id.isEmpty ? Text('צור מרפאה חדשה') : Text('ערוך מרפאה'),
            content: SingleChildScrollView(
              child: ClinicForm(_formKey, clinic),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('שמור'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();

                    Future<void> ref;
                    if (clinic.id.isEmpty) {
                      ref = Firestore.instance
                          .collection("clinics")
                          .add(clinic.toJson());
                    } else {
                      ref = Firestore.instance
                          .collection("clinics")
                          .document(clinic.id)
                          .setData(clinic.toJson(), merge: true);
                    }

                    ref
                        .then(Navigator.of(context).pop)
                        .then((res) => showInfoFlushbar(
                            context,
                            '',
                            clinic.id.isEmpty
                                ? 'המרפאה נוצרה בהצלח.'
                                : 'המרפאה עודכנה בהצלח.'))
                        .catchError((err) =>
                            showInfoFlushbar(context, '', err.toString()));
                  }
                },
              ),
              FlatButton(
                child: Text('בטל'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<void> _deleteClinicDialog(BuildContext context, Clinic clinic) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('מיחקת מרפאה'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('האם אתה בטוח, שברצונך למחוק את המרפאה?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('כן'),
              onPressed: () => Firestore.instance
                  .collection("clinics")
                  .document(clinic.id)
                  .delete()
                  .then(Navigator.of(context).pop)
                  .catchError((err) => showInfoFlushbar(
                      context, 'לא יכול למחוק מרפאה', err.toString())),
            ),
            FlatButton(
              child: Text('לא'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ClinicForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Clinic clinic;

  ClinicForm(this.formKey, this.clinic);

  @override
  ClinicFormState createState() {
    return ClinicFormState(this.formKey, this.clinic);
  }
}

class ClinicFormState extends State<ClinicForm> {
  final GlobalKey<FormState> _formKey;
  Clinic clinic;

  ClinicFormState(this._formKey, this.clinic);

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      autovalidate: true,
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            initialValue: this.clinic.name,
            decoration: const InputDecoration(labelText: 'שם'),
            keyboardType: TextInputType.text,
            onSaved: (value) => this.clinic.name = value,
            validator: (value) {
              if (value.isEmpty) {
                return 'אנא הכנס שם';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: this.clinic.doctorProcent.toString(),
            decoration: const InputDecoration(labelText: 'אחוז'),
            keyboardType: TextInputType.number,
            onSaved: (value) =>
                this.clinic.doctorProcent = double.tryParse(value),
            validator: (value) {
              if (value.isEmpty) {
                return 'אחוז שדה נדרש';
              }

              if (!isFloat(value)) {
                return 'אנא הכנס מספר בלבד';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: this.clinic.description,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'תיאור'),
            keyboardType: TextInputType.multiline,
            onSaved: (value) => this.clinic.description = value,
            validator: (value) {
              if (value.isEmpty) {
                return 'אנא הכנס תיאור';
              }
              return null;
            },
          )
        ],
      ),
    );
  }
}
