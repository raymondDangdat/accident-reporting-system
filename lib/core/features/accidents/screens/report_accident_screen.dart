import 'dart:io';
import 'package:ars/core/widgets/app_button.dart';
import 'package:ars/core/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReportAccidentScreen extends StatefulWidget {
  const ReportAccidentScreen({super.key});

  @override
  State<ReportAccidentScreen> createState() => _ReportAccidentScreenState();
}

class _ReportAccidentScreenState extends State<ReportAccidentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
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

  /// Pick accident photo
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  /// Upload accident photo to Firebase Storage
  Future<String?> _uploadImage(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("accident_photos")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  /// Pick a date
  Future<void> _pickDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = DateFormat("yyyy-MM-dd").format(pickedDate);
    }
  }

  /// Pick a time
  Future<void> _pickTime(TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      controller.text = DateFormat("HH:mm").format(dt);
    }
  }

  /// Submit accident report
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Upload image if available
      String? photoUrl;
      if (pickedImage != null) {
        photoUrl = await _uploadImage(pickedImage!);
      }

      // Save report in Firestore
      await FirebaseFirestore.instance.collection("accidents").add({
        "date": dateController.text,
        "crashTime": crashTimeController.text,
        "reportTime": reportTimeController.text,
        "arrivalTime": arrivalTimeController.text,
        "responseTime": responseTimeController.text,
        "route": routeController.text,
        "location": locationController.text,
        "noOfVehicles": int.tryParse(noOfVehiclesController.text) ?? 0,
        "vehicleRegNo": vehicleRegController.text,
        "vehicleCategory": vehicleCategoryController.text,
        "vehicleMake": vehicleMakeController.text,
        "officerId": FirebaseAuth.instance.currentUser?.uid ?? '',
        "vehicleType": vehicleTypeController.text,
        "vehicleColor": vehicleColorController.text,
        "fleetName": fleetNameController.text,
        "driverName": driverNameController.text,
        "noPeopleInvolved": int.tryParse(noPeopleInvolvedController.text) ?? 0,
        "noInjured": int.tryParse(noInjuredController.text) ?? 0,
        "noNotInjured": int.tryParse(noNotInjuredController.text) ?? 0,
        "noKilled": int.tryParse(noKilledController.text) ?? 0,
        "typeOfInjury": typeOfInjuryController.text,
        "typeOfRtc": typeOfRtcController.text,
        "probableCauses": probableCausesController.text,
        "itemsRecovered": itemsRecoveredController.text,
        "actionTaken": actionTakenController.text,
        "photoUrl": photoUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Accident reported successfully!")),
        );
        // Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Accident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ExpansionTile(
                title: const Text("Accident Info"),
                initiallyExpanded: true,
                children: [
                  _buildDateField(dateController, 'Date'),
                  _buildTimeField(crashTimeController, 'Crash Time'),
                  _buildTimeField(reportTimeController, 'Report Time'),
                  _buildTimeField(arrivalTimeController, 'Arrival Time'),
                  _buildTimeField(responseTimeController, 'Response Time'),
                  _buildTextField(routeController, 'Route'),
                  _buildTextField(locationController, 'Location'),
                ],
              ),
              ExpansionTile(
                title: const Text("Vehicle Details"),
                children: [
                  _buildTextField(noOfVehiclesController, 'No of Vehicles Involved', isNumber: true),
                  _buildTextField(vehicleRegController, 'Vehicle Reg No'),
                  _buildTextField(vehicleCategoryController, 'Vehicle Category'),
                  _buildTextField(vehicleMakeController, 'Vehicle Make'),
                  _buildTextField(vehicleTypeController, 'Vehicle Type'),
                  _buildTextField(vehicleColorController, 'Vehicle Color'),
                  _buildTextField(fleetNameController, 'Name of Fleet'),
                  _buildTextField(driverNameController, 'Driver Name'),
                ],
              ),
              ExpansionTile(
                title: const Text("Casualties"),
                children: [
                  _buildTextField(noPeopleInvolvedController, 'No People Involved', isNumber: true),
                  _buildTextField(noInjuredController, 'No Injured', isNumber: true),
                  _buildTextField(noNotInjuredController, 'No Not Injured', isNumber: true),
                  _buildTextField(noKilledController, 'No Killed', isNumber: true),
                ],
              ),
              ExpansionTile(
                title: const Text("Investigation & Actions"),
                children: [
                  _buildTextField(typeOfInjuryController, 'Type of Injury'),
                  _buildTextField(typeOfRtcController, 'Type of RTC'),
                  _buildTextField(probableCausesController, 'Probable Causes of Crash'),
                  _buildTextField(itemsRecoveredController, 'Items Recovered'),
                  _buildTextField(actionTakenController, 'Action Taken'),
                ],
              ),
              ExpansionTile(
                title: const Text("Photo Evidence"),
                children: [
                  pickedImage != null
                      ? Image.file(pickedImage!, height: 150)
                      : const Text("No image selected"),
                  TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Capture Scene Photo"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const LoadingAnimation()
                  : GradientButton(onTap: (){
                    _submitReport();
              }, label: "Submit Report",),
            ],
          ),
        ),
      ),
    );
  }

  /// Standard text field
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  /// Date field with picker
  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _pickDate(controller),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  /// Time field with picker
  Widget _buildTimeField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        onTap: () => _pickTime(controller),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}