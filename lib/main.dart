import 'package:flutter/material.dart';
import 'package:salary_calc/pages/login_page.dart';
import 'package:salary_calc/services/authentication.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    initializeDateFormatting('he');

    return MaterialApp(
      /*supportedLocales: [
        const Locale('he')
      ],*/
      title: 'Salary Calc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(auth: new Auth()),
      builder: (BuildContext context, Widget child) {
        return new Directionality(
          textDirection: TextDirection.rtl,
          child: new Builder(
            builder: (BuildContext context) {
              return new MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
