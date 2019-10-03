import 'package:rxdart/rxdart.dart';
import 'package:salary_calc/models/clinic.dart';

class ClinicBloc {
  Clinic initialClinic; //if the data is not passed by paramether it initializes with 0
  BehaviorSubject<Clinic> _subjectClinic;

  ClinicBloc({this.initialClinic}){
    _subjectClinic = new BehaviorSubject<Clinic>.seeded(this.initialClinic); //initializes the subject with element already
  }

  Observable<Clinic> get clinicObservable => _subjectClinic.stream;

  void update(Clinic clinic){
    _subjectClinic.sink.add(clinic);
  }

  void dispose(){
    _subjectClinic.close();
  }
}