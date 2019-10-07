import 'package:flutter/material.dart';
import 'package:salary_calc/models/visit.dart';
import 'package:intl/intl.dart';

class VisitRow extends StatelessWidget {
  final Visit visit;

  VisitRow(this.visit);

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = const TextStyle(fontFamily: 'Poppins');
    final regularTextStyle = baseTextStyle.copyWith(
        color: const Color(0xffb6b2df),
        fontSize: 12.0,
        fontWeight: FontWeight.w400);
    final subHeaderTextStyle = regularTextStyle.copyWith(fontSize: 12.0);
    final headerTextStyle = baseTextStyle.copyWith(
        color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600);

    Widget _clinicValue({String value}) {
      return Row(children: <Widget>[
        Container(width: 8.0),
        Text(value, style: regularTextStyle),
      ]);
    }

    final clinicCardContent = Container(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(this.visit.name, style: headerTextStyle),
              ),
              Container(
                child: Text(
                    DateFormat.yMMMMEEEEd('he')
                        .format(this.visit.createdAt.toDate()),
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: const Color(0xffb6b2df),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          Container(height: 5.0),
          Text(this.visit.description,
              style: subHeaderTextStyle,
              overflow: TextOverflow.fade,
              softWrap: false),
          Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              height: 2.0,
              width: 18.0,
              color: Color(0xff00c6ff)),
          Row(
            children: <Widget>[
              Expanded(child: _clinicValue(value: 'מחיר')),
              Expanded(child: _clinicValue(value: this.visit.cost.toString()))
            ],
          ),
        ],
      ),
    );

    final clinicCard = Container(
      child: clinicCardContent,
      height: 124.0,
      decoration: BoxDecoration(
        color: Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
    );

    return Container(
        height: 120.0,
        margin: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Stack(
          children: <Widget>[
            clinicCard,
          ],
        ));
  }
}
