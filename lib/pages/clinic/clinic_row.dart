import 'package:flutter/material.dart';
import 'package:salary_calc/models/clinic.dart';

class ClinicRow extends StatelessWidget {

  final Clinic clinic;

  ClinicRow(this.clinic);

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = const TextStyle(
        fontFamily: 'Poppins'
    );
    final regularTextStyle = baseTextStyle.copyWith(
        color: const Color(0xffb6b2df),
        fontSize: 12.0,
        fontWeight: FontWeight.w400
    );
    final subHeaderTextStyle = regularTextStyle.copyWith(
        fontSize: 12.0
    );
    final headerTextStyle = baseTextStyle.copyWith(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.w600
    );

    Widget _clinicValue({String value}) {
      return new Row(
          children: <Widget>[
            new Container(width: 8.0),
            new Text(value, style: regularTextStyle),
          ]
      );
    }


    final clinicCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(height: 4.0),
          new Text(this.clinic.name, style: headerTextStyle),
          new Container(height: 5.0),
          new Text(
              this.clinic.description,
              style: subHeaderTextStyle,
              overflow: TextOverflow.fade,
              softWrap: false
          ),
          new Container(
              margin: new EdgeInsets.symmetric(vertical: 8.0),
              height: 2.0,
              width: 18.0,
              color: new Color(0xff00c6ff)
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                  child: _clinicValue(
                      value: 'אחוז:'
                  )
              ),
              new Expanded(
                  child: _clinicValue(
                      value: this.clinic.doctorProcent.toString()
                  )
              )
            ],
          ),
        ],
      ),
    );


    final clinicCard = new Container(
      child: clinicCardContent,
      height: 124.0,
      //margin: new EdgeInsets.only(left: 46.0),
      decoration: new BoxDecoration(
        color: new Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0),
          ),
        ],
      ),
    );


    return new Container(
      height: 120.0,
      margin: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 10.0,
      ),
      child: new Stack(
        children: <Widget>[
          clinicCard,
        ],
      )
    );
  }
}