import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/accident_provider.dart';

class ReportAccidentScreen extends StatefulWidget {
  const ReportAccidentScreen({super.key});

  @override
  State<ReportAccidentScreen> createState() => _ReportAccidentScreenState();
}

class _ReportAccidentScreenState extends State<ReportAccidentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController crashTimeController = TextEditingController();
  final TextEditingController reportTimeController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();
  final TextEditingController responseTimeController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController noOfVehiclesController = TextEditingController();
  final TextEditingController vehicleRegController = TextEditingController();
  final TextEditingController vehicleCategoryController = TextEditingController();
  final TextEditingController vehicleMakeController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController fleetNameController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController noPeopleInvolvedController = TextEditingController();
  final TextEditingController noInjuredController = TextEditingController();
  final TextEditingController noNotInjuredController = TextEditingController();
  final TextEditingController noKilledController = TextEditingController();
  final TextEditingController typeOfInjuryController = TextEditingController();
  final TextEditingController typeOfRtcController = TextEditingController();
  final TextEditingController probableCausesController = TextEditingController();
  final TextEditingController itemsRecoveredController = TextEditingController();
  final TextEditingController actionTakenController = TextEditingController();

  File? pickedImage;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accidentsProvider = Provider.of<AccidentsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Accident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(dateController, 'Date'),
              _buildTextField(crashTimeController, 'Crash Time'),
              _buildTextField(reportTimeController, 'Report Time'),
              _buildTextField(arrivalTimeController, 'Arrival Time'),
              _buildTextField(responseTimeController, 'Response Time'),
              _buildTextField(routeController, 'Route'),
              _buildTextField(locationController, 'Location'),
              _buildTextField(noOfVehiclesController, 'No of Vehicles Involved', isNumber: true),
              _buildTextField(vehicleRegController, 'Vehicle Reg No'),
              _buildTextField(vehicleCategoryController, 'Vehicle Category'),
              _buildTextField(vehicleMakeController, 'Vehicle Make'),
              _buildTextField(vehicleTypeController, 'Vehicle Type'),
              _buildTextField(vehicleColorController, 'Vehicle Color'),
              _buildTextField(fleetNameController, 'Name of Fleet'),
              _buildTextField(driverNameController, 'Driver Name'),
              _buildTextField(noPeopleInvolvedController, 'No People Involved', isNumber: true),
              _buildTextField(noInjuredController, 'No Injured', isNumber: true),
              _buildTextField(noNotInjuredController, 'No Not Injured', isNumber: true),
              _buildTextField(noKilledController, 'No Killed', isNumber: true),
              _buildTextField(typeOfInjuryController, 'Type of Injury'),
              _buildTextField(typeOfRtcController, 'Type of RTC'),
              _buildTextField(probableCausesController, 'Probable Causes of Crash'),
              _buildTextField(itemsRecoveredController, 'Items Recovered'),
              _buildTextField(actionTakenController, 'Action Taken'),
              const SizedBox(height: 12),
              pickedImage != null
                  ? Image.file(pickedImage!, height: 150)
                  : const Text('No image selected'),
              TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Scene Photo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await accidentsProvider.reportAccident(
                      date: dateController.text,
                      crashTime: crashTimeController.text,
                      reportTime: reportTimeController.text,
                      arrivalTime: arrivalTimeController.text,
                      responseTime: responseTimeController.text,
                      route: routeController.text,
                      location: locationController.text,
                      noOfVehicles: int.tryParse(noOfVehiclesController.text) ?? 0,
                      vehicleRegNo: vehicleRegController.text,
                      vehicleCategory: vehicleCategoryController.text,
                      vehicleMake: vehicleMakeController.text,
                      vehicleType: vehicleTypeController.text,
                      vehicleColor: vehicleColorController.text,
                      fleetName: fleetNameController.text,
                      driverName: driverNameController.text,
                      noPeopleInvolved: int.tryParse(noPeopleInvolvedController.text) ?? 0,
                      noInjured: int.tryParse(noInjuredController.text) ?? 0,
                      noNotInjured: int.tryParse(noNotInjuredController.text) ?? 0,
                      noKilled: int.tryParse(noKilledController.text) ?? 0,
                      typeOfInjury: typeOfInjuryController.text,
                      typeOfRtc: typeOfRtcController.text,
                      probableCauses: probableCausesController.text,
                      itemsRecovered: itemsRecoveredController.text,
                      actionTaken: actionTakenController.text,
                      photoFile: pickedImage,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Accident reported successfully!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }
}