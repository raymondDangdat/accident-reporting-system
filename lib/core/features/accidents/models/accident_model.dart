class AccidentModel {
  final dynamic id;
  final dynamic officerId;
  final DateTime date;
  final dynamic crashTime;
  final dynamic reportTime;
  final dynamic arrivalTime;
  final dynamic responseTime;
  final dynamic route;
  final dynamic location;
  final dynamic noOfVehicles;
  final dynamic vehicleRegNo;
  final dynamic vehicleCategory;
  final dynamic vehicleMake;
  final dynamic vehicleType;
  final dynamic vehicleColor;
  final dynamic fleetName;
  final dynamic driverName;
  final dynamic noPeopleInvolved;
  final dynamic noInjured;
  final dynamic noNotInjured;
  final dynamic noKilled;
  final dynamic typeOfInjury;
  final dynamic typeOfRtc;
  final dynamic probableCauses;
  final dynamic itemsRecovered;
  final dynamic actionTaken;
  final dynamic photoUrl;
  final DateTime createdAt;

  AccidentModel({
    required this.id,
    required this.officerId,
    required this.date,
    required this.crashTime,
    required this.reportTime,
    required this.arrivalTime,
    required this.responseTime,
    required this.route,
    required this.location,
    required this.noOfVehicles,
    required this.vehicleRegNo,
    required this.vehicleCategory,
    required this.vehicleMake,
    required this.vehicleType,
    required this.vehicleColor,
    required this.fleetName,
    required this.driverName,
    required this.noPeopleInvolved,
    required this.noInjured,
    required this.noNotInjured,
    required this.noKilled,
    required this.typeOfInjury,
    required this.typeOfRtc,
    required this.probableCauses,
    required this.itemsRecovered,
    required this.actionTaken,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'officerId': officerId,
    'date': date.toIso8601String(),
    'crashTime': crashTime,
    'reportTime': reportTime,
    'arrivalTime': arrivalTime,
    'responseTime': responseTime,
    'route': route,
    'location': location,
    'noOfVehicles': noOfVehicles,
    'vehicleRegNo': vehicleRegNo,
    'vehicleCategory': vehicleCategory,
    'vehicleMake': vehicleMake,
    'vehicleType': vehicleType,
    'vehicleColor': vehicleColor,
    'fleetName': fleetName,
    'driverName': driverName,
    'noPeopleInvolved': noPeopleInvolved,
    'noInjured': noInjured,
    'noNotInjured': noNotInjured,
    'noKilled': noKilled,
    'typeOfInjury': typeOfInjury,
    'typeOfRtc': typeOfRtc,
    'probableCauses': probableCauses,
    'itemsRecovered': itemsRecovered,
    'actionTaken': actionTaken,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
  };
}