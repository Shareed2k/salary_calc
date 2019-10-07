import 'package:flutter/material.dart';
import 'package:salary_calc/models/clinic.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class ClinicSummary extends StatelessWidget {
  final Clinic clinic;

  ClinicSummary(this.clinic);

  @override
  Widget build(BuildContext context) {

    Widget _clinicValue({double value}) {
      MoneyFormatterOutput amount = new FlutterMoneyFormatter(
        amount: value,
        settings: MoneyFormatterSettings(
          symbol: '₪',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 2
        )
      ).output;

      return Container(
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //new Image.asset(image, height: 12.0)
              Container(width: 8.0),
              Text(amount.compactSymbolOnLeft, style: TextStyle(
                color: const Color(0xffb6b2df),
                fontFamily: 'Poppins',
                fontSize: 15.0,
              )),
            ]
        ),
      );
    }

    final clinicCardContent = Container(
      margin: EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'מרפאה',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.w600
            )
          ),
          Text(this.clinic.name, style: TextStyle(
              fontFamily: 'Poppins',
              color: const Color(0xffb6b2df),
              fontSize: 14.0,
              fontWeight: FontWeight.w400
          )),
          Container(height: 10.0),
          Text(this.clinic.description, style: TextStyle(
              fontFamily: 'Poppins',
              color: const Color(0xffb6b2df),
              fontSize: 14.0,
              fontWeight: FontWeight.w400
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
            maxLines: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'רווח:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600
                  )
              ),
              Expanded(
                  flex: 0,
                  child: _clinicValue(
                      value: this.clinic.employeePart
                  )
              ),
              Container(
                width: 32.0,
              ),
              Text(
                'רווח המרפאה:',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600
                )
              ),
              Expanded(
                  flex: 0,
                  child: _clinicValue(
                      value: this.clinic.clinicPart
                  )
              )
            ],
          ),
        ],
      ),
    );


    final clinicCard = Container(
      child: clinicCardContent,
      height: 154.0,
      margin: EdgeInsets.only(top: 0),
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


    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        child: Stack(
          children: <Widget>[
            clinicCard
          ],
        ),
      )
    );
  }
}