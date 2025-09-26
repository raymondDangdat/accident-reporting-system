import 'package:flutter/material.dart';

class AccidentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const AccidentDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accident Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['photoUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['photoUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _buildDetail("Date", data['date']),
            _buildDetail("Crash Time", data['crashTime']),
            _buildDetail("Report Time", data['reportTime']),
            _buildDetail("Arrival Time", data['arrivalTime']),
            _buildDetail("Response Time", data['responseTime']),
            _buildDetail("Route", data['route']),
            _buildDetail("Location", data['location']),
            _buildDetail("No of Vehicles", data['noOfVehicles'].toString()),
            _buildDetail("Vehicle Reg No", data['vehicleRegNo']),
            _buildDetail("Vehicle Category", data['vehicleCategory']),
            _buildDetail("Vehicle Make", data['vehicleMake']),
            _buildDetail("Vehicle Type", data['vehicleType']),
            _buildDetail("Vehicle Color", data['vehicleColor']),
            _buildDetail("Fleet Name", data['fleetName']),
            _buildDetail("Driver Name", data['driverName']),
            _buildDetail("No People Involved", data['noPeopleInvolved'].toString()),
            _buildDetail("No Injured", data['noInjured'].toString()),
            _buildDetail("No Not Injured", data['noNotInjured'].toString()),
            _buildDetail("No Killed", data['noKilled'].toString()),
            _buildDetail("Type of Injury", data['typeOfInjury']),
            _buildDetail("Type of RTC", data['typeOfRtc']),
            _buildDetail("Probable Causes", data['probableCauses']),
            _buildDetail("Items Recovered", data['itemsRecovered']),
            _buildDetail("Action Taken", data['actionTaken']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value ?? "N/A"),
          ),
        ],
      ),
    );
  }
}