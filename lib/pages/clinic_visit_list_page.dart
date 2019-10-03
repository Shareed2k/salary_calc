import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:salary_calc/bloc/clinic_bloc.dart';
import 'package:salary_calc/models/clinic.dart';
import 'package:salary_calc/models/visit.dart';
import 'package:validators/validators.dart';

import 'clinic/clinic_summary.dart';
import 'clinic/visit_row.dart';
import 'clinic_visits_report_page.dart';

// ignore: must_be_immutable
class VisitListPage extends StatelessWidget {
  final FirebaseUser user;
  final Clinic clinic;
  ClinicBloc clinicBloc;

  List visitList = [];

  VisitListPage({@required this.user, @required this.clinic});


  @override
  Widget build(BuildContext context) {
    clinicBloc = ClinicBloc(initialClinic: this.clinic);

    return Scaffold(
      backgroundColor: Color(0xFF736AB7),
      appBar: AppBar(
        title: Text('ביקורים'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: Icon(
              Icons.add_to_queue,
              color: Colors.white,
            ),
            onPressed: () => _createVisitDialog(context),
          ),
          IconButton(
            icon: Icon(
              Icons.assessment,
              color: Colors.white,
            ),
            onPressed: () => _priviewClinicReport(context),
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Color(0xFF736AB7),
        child: Stack (
          children: <Widget>[
            //_getBackground(),
            _getGradient(),
            StreamBuilder(
                stream: clinicBloc.clinicObservable,
                initialData: this.clinic,
                builder: (BuildContext context, AsyncSnapshot<Clinic> snapshot){
                  return ClinicSummary(snapshot.data);
                }
            ),
            _getContent(),
          ],
        ),
      ),
    );
  }

  Future _priviewClinicReport(context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => new PreviewScreenshot(visitList: this.visitList),
      ),
    );
  }

  /*Container _getBackground () {
    return new Container(
      child: new Image.network(planet.picture,
        fit: BoxFit.cover,
        height: 300.0,
      ),
      constraints: new BoxConstraints.expand(height: 295.0),
    );
  }*/

  Container _getGradient() {
    return Container(
      margin: EdgeInsets.only(top: 190.0),
      height: 110.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0x00736AB7),
            Color(0xFF736AB7)
          ],
          stops: [0.0, 0.9],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
        ),
      ),
    );
  }

  Container _getContent() {
    final DateTime date = DateTime.now();

    return Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 170, 0, 0),
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('visits')
                    .where('uid', isEqualTo: this.user.uid)
                    .where('cid', isEqualTo: this.clinic.id)
                    .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, 1)))
                    .orderBy('created_at', descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Text('Loading...');

                  // reset vars
                  this.clinic.clinicPart = 0;
                  this.clinic.employeePart = 0;
                  this.visitList = [];

                  this.clinic.visits = snapshot.data.documents;

                  return ListView(
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      Visit visit = Visit.fromJson(document);
                      double doctorPart = visit.cost * this.clinic.doctorProcent;

                      this.clinic.clinicPart += doctorPart;
                      this.clinic.employeePart += visit.cost - doctorPart;

                      clinicBloc.update(this.clinic);

                      this.visitList.add(visit.toJsonShort());

                      return _setList(context, visit);
                    }).toList(),
                  );
                },
              ),
              ),
            )
        ],
      ),
    );
  }

  Widget _setList (BuildContext context, Visit visit) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Color(0xFF736AB7),
        child: InkWell(
          child: VisitRow(visit),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'מחק',
          color: Color(0xFF736AB7),
          icon: Icons.delete,
          onTap: () => _deleteVisitDialog(context, visit),
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'ערוך',
          color: Color(0xFF736AB7),
          icon: Icons.edit,
          onTap: () => _createVisitDialog(context, visit: visit),
        )
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
  Future<void> _createVisitDialog(BuildContext context, {Visit visit = null}) async {
    final _formKey = GlobalKey<FormState>();

    if (visit == null)
      visit = Visit(this.user.uid);

    visit.cid = this.clinic.id;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: visit.id.isEmpty ? Text('צור ביקור חדש') : Text('ערוך ביקור'),
          content: SingleChildScrollView(
            child: VisitForm(_formKey, visit),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('שמור'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  Future<void> ref;
                  if (visit.id.isEmpty) {
                    ref = Firestore.instance.collection("visits").add(visit.toJson());
                  } else {
                    ref = Firestore.instance.collection("visits")
                        .document(visit.id).setData(visit.toJson(), merge: true);
                  }

                  ref
                      .then(Navigator.of(context).pop)
                      .then((res) => showInfoFlushbar(context, '', visit.id.isEmpty ? 'ביקור נוצר בהצלח.' : 'ביקור עודכן בהצלח.'))
                      .catchError((err) => showInfoFlushbar(context, '', err.toString()));
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

  Future<void> _deleteVisitDialog(BuildContext context, Visit visit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('מיחקת ביקור'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('האם אתה בטוח, שברצונך למחוק את הביקור?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('כן'),
              onPressed: () => Firestore.instance.collection("visits").document(visit.id).delete()
                  .then(Navigator.of(context).pop)
                  .catchError((err) => showInfoFlushbar(context, 'לא יכול למחוק ביקור', err.toString())),
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

class VisitForm extends StatefulWidget {

  final GlobalKey<FormState> formKey;
  final Visit visit;

  VisitForm(this.formKey, this.visit);

  @override
  VisitFormState createState() {
    return VisitFormState(this.formKey, this.visit);
  }
}

class VisitFormState extends State<VisitForm> {
  final GlobalKey<FormState> _formKey;
  Visit visit;

  VisitFormState(this._formKey, this.visit);

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
            initialValue: this.visit.name,
            decoration: const InputDecoration(labelText: 'שם'),
            keyboardType: TextInputType.text,
            onSaved: (value)  => this.visit.name = value,
            validator: (value) {
              if (value.isEmpty) {
                return 'אנא הכנס שם';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: this.visit.cost.toString(),
            decoration: const InputDecoration(labelText: 'מחיר'),
            keyboardType: TextInputType.number,
            onSaved: (value)  => this.visit.cost = double.tryParse(value),
            validator: (value) {
              if (value.isEmpty) {
                return 'מחיר שדה נדרש';
              }

              if (!isFloat(value)) {
                return 'אנא הכנס מספר בלבד';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: this.visit.description,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'תיאור'),
            keyboardType: TextInputType.multiline,
            onSaved: (value)  => this.visit.description = value,
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