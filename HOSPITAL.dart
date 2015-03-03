/**
* partial solution SPOJ HOSPITAL problem. This answer leaves out the table
* indicating the total use time and usage amount for each operating table
* and recovery room. This is just a solution to the scheduling portion
* of the algorithm.
*/

import 'dart:io';

const int NO_PATIENT = -1;
int OPERATING_TABLE_COUNT = 5;
int RECOVERTY_BED_COUNT = 5;
int _START_HOUR = 7;
int START_TIME = _START_HOUR*60;
int TRANSPORT_TIME = 5;
int OPERATING_TABLE_PREP_TIME = 15;
int RECOVERTY_BED_PREP_TIME = 10;
int TOTAL_PATIENTS = 16;

class Patient {
  final String name;
  final int operationTime;
  final int recoveryTime;
  int operationStart;
  int recoveryStart;
  int table;
  int bed;
  Patient(this.name, this.operationTime, this.recoveryTime);
}

class HospitalRoom {
  int openTime;
  int patient;
  HospitalRoom.fromOpenTime(this.openTime)
    : patient = NO_PATIENT;
  HospitalRoom()
    : patient = NO_PATIENT;
}

List tables = new List<HospitalRoom>.generate(OPERATING_TABLE_COUNT, (_) => new HospitalRoom.fromOpenTime(START_TIME));
List beds = new List<HospitalRoom>.generate(RECOVERTY_BED_COUNT, (_) => new HospitalRoom.fromOpenTime(START_TIME));
List patients = [];
int nextPatient = 0;

void ParseHeader() {
  List header = stdin.readLineSync().split(' ');
  OPERATING_TABLE_COUNT = int.parse(header[0]);
  RECOVERTY_BED_COUNT   = int.parse(header[1]);
  _START_HOUR           = int.parse(header[2]);
  START_TIME            = _START_HOUR*60;
  TRANSPORT_TIME        = int.parse(header[3]);
  OPERATING_TABLE_PREP_TIME = int.parse(header[4]);
  RECOVERTY_BED_PREP_TIME   = int.parse(header[5]);
  TOTAL_PATIENTS = int.parse(header[6]);
}

void ParsePatientList() {
  for (int i=0; i<TOTAL_PATIENTS; i++) {
    var name = stdin.readLineSync(),
        times = stdin.readLineSync().split(' '),
        operationTime = int.parse(times[0]),
        recoveryTime  = int.parse(times[1]);
    patients.add(new Patient(name, operationTime, recoveryTime));
  }
}

int GetNextPatient() {
  nextPatient += 1;
  return nextPatient - 1;
} 

bool AtLeastOneTableIsBusy() => 
  tables.any((t) => t.patient != NO_PATIENT);

bool PatientsAreStillWaiting() => 
  nextPatient < patients.length;

int RemoveEarliestOperationPatient() {
  int earliest = 0, patient;
  for (var i=0; i<tables.length; i++) {
    if (tables[earliest].patient == NO_PATIENT ||
        (tables[i].openTime < tables[earliest].openTime &&
         tables[i].patient != NO_PATIENT)) {
      earliest = i;
    }
  }
  patient = tables[earliest].patient;
  tables[earliest].patient = NO_PATIENT;
  return patient;
}

void BeginPatientOperation(int patient) {
  //print("Operating on patient ${patient}");
  int earliest = 0;
  for (var i=0; i<tables.length; i++) {
    if (tables[i].openTime < tables[earliest].openTime) {
      earliest = i;
    }
  }
  tables[earliest].patient = patient;
  patients[patient].operationStart = tables[earliest].openTime;
  patients[patient].table = earliest+1;
  tables[earliest].openTime += patients[patient].operationTime;
  tables[earliest].openTime += OPERATING_TABLE_PREP_TIME;
}

void MovePatientToBed(int patient) {
  //print("Moving patient ${patient} to Recovery Bed");
  int earliest = 0;
  for (var i=0; i<beds.length; i++) {
    if (beds[i].openTime < beds[earliest].openTime) {
      earliest = i;
    }
  }
  patients[patient].recoveryStart = patients[patient].operationStart +
                                    patients[patient].operationTime +
                                    TRANSPORT_TIME;
  patients[patient].bed = earliest+1;
  beds[earliest].patient = patient;
  beds[earliest].openTime += patients[patient].recoveryTime;
  beds[earliest].openTime += RECOVERTY_BED_PREP_TIME;
}

String _secsToMins(int sec) {
  String minutes = "${(sec/60).floor()}",
         seconds = "${(sec % 60)}".padLeft(2, "0");
  return "$minutes:$seconds";
}

void ComputeSchedule() {
  BeginPatientOperation(GetNextPatient());
  while (AtLeastOneTableIsBusy()) {
    var patient = RemoveEarliestOperationPatient();
    MovePatientToBed(patient);
    if (PatientsAreStillWaiting()) {
      BeginPatientOperation(GetNextPatient());
    }
  }
}

main () {
  ParseHeader();
  ParsePatientList();
  ComputeSchedule();
  print("Patient          Operating Room          Recovery Room");
  print("#  Name     Room#  Begin   End      Bed#  Begin    End");
  print("------------------------------------------------------");
  for (var i=0; i<patients.length; i++) {
      var patient = patients[i];
      stdout.write("${i+1}".padRight(3, ' '));
      stdout.write(patient.name.padRight(11, ' '));
      stdout.write("${patient.table}".padRight(5, ' '));
      stdout.write(_secsToMins(patient.operationStart).padRight(8, ' '));
      stdout.write(_secsToMins(patient.operationStart+patient.operationTime).padRight(10, ' '));
      stdout.write("${patient.bed}".padRight(5, ' '));
      stdout.write(_secsToMins(patient.recoveryStart).padRight(8, ' '));
      stdout.write(_secsToMins(patient.recoveryStart + patient.recoveryTime));
      stdout.writeln();
  }
}