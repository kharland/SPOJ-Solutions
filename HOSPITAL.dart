/**
SPOJ HOSPITAL problem
*/

import 'dart:io';

const int NO_PATIENT = -1;
const int OPERATING_TABLE_COUNT = 5;
const int RECOVERTY_BED_COUNT = 5;
const int _START_HOUR = 7;
const int START_TIME = _START_HOUR*60;
const int TRANSPORT_TIME = 5;
const int OPERATING_TABLE_PREP_TIME = 15;
const int RECOVERTY_BED_PREP_TIME = 10;
const int TOTAL_PATIENTS = 16;

class Patient {
  final String name;
  final int operationTime;
  final int recoveryTime;
  int operationStart;
  int recoveryStart;
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
List patients = [
  new Patient("Jones", 28, 140),
  new Patient("Smith", 120, 200),
  new Patient("Thompson", 23, 75),
  new Patient("Albright", 19, 82),
  new Patient("Poucher", 133, 209),
  new Patient("Comer", 74, 101),
  new Patient("Perry", 93, 188),
  new Patient("Page", 111, 223),
  new Patient("Roggio", 69, 122),
  new Patient("Brigham", 42, 79),
  new Patient("Nute", 22, 71),
  new Patient("Young", 38, 140),
  new Patient("Bush", 26, 121),
  new Patient("Cates", 120, 248),
  new Patient("Johnson", 86, 181),
  new Patient("White", 92, 140)
];
int nextPatient = 0;

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
  beds[earliest].patient = patient;
  beds[earliest].openTime += patients[patient].recoveryTime;
  beds[earliest].openTime += RECOVERTY_BED_PREP_TIME;
}

String _secsToMins(int sec) {
  String minutes = "${(sec/60).floor()}".padLeft(2, "0"),
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
  ComputeSchedule();
  for (var patient in patients) {
      stdout.write(patient.name.padRight(10, ' '));
      stdout.write(_secsToMins(patient.operationStart));
      stdout.write("-");
      stdout.write(_secsToMins(patient.operationStart + patient.operationTime));
      stdout.write("   ");
      stdout.write(_secsToMins(patient.recoveryStart));
      stdout.write("-");
      stdout.write(_secsToMins(patient.recoveryStart + patient.recoveryTime));
      stdout.writeln();
  }
}
