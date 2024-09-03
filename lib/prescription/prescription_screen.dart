import 'package:doctor_prescription_app/data/pdf_work.dart';
import 'package:doctor_prescription_app/getx/prescription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrescriptionScreen extends StatefulWidget {

  PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final PrescriptionController controller = Get.put(PrescriptionController());

  Future<Map<String, String>?> _showPatientDetailsDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Enter Patient Details',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
              ),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                MethodsClass().generateAndSavePrescriptionPDF(
                  patientName: nameController.text.trim(),
                  mobileNumber: mobileController.text.trim(),
                  prescriptionText: controller.prescriptions.map((item) =>
                  '${item.medicineName} (${item.type}) - ${item.dosage}').join('\n'),
                );
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'mobile': mobileController.text.trim(),
                });
              },
              child: const Text('Generate PDF'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.prescriptions.length,
                itemBuilder: (context, index) {
                  return _buildPrescriptionItem(context, index);
                },
              )),
              TextField(
                focusNode: controller.focusNode,
                controller: controller.textController,
                maxLines: null,
                textInputAction: TextInputAction.done,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                cursorHeight: 24,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  hintText: 'Write Prescription',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onChanged: (text) {
                  setState(() {

                  });
                },
                onSubmitted: (text) {
                  controller.addPrescriptionItem(text);
                  controller.textController.clear();
                },
              ),
              const SizedBox(height: 32,),
              controller.prescriptions.isNotEmpty
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showPatientDetailsDialog(context),
                      child: const Text(
                        'Share Prescription',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                      ),
                    ),
                  ],
                )
                    : Container()
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
        onPressed: controller.isListening.value
            ? controller.stopListening
            : controller.startListening,
        tooltip: controller.isListening.value ? 'Stop Listening' : 'Start Listening',
        label: const Text(
          'Add to Speak',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
        icon: Icon(controller.isListening.value ? Icons.mic : Icons.mic_none),
      )),
    );
  }

  Widget _buildPrescriptionItem(BuildContext context, int index) {
    final item = controller.prescriptions[index];

    // Ensure initial type and dosage are valid
    if (item.type != 'Tablet' && item.type != 'Capsule' && item.type != 'Syrup') {
      item.type = 'Tablet'; // or any default value
    }

    if (item.type == 'Syrup') {
      if (item.dosage != '5 ml' && item.dosage != '7 ml' && item.dosage != '10 ml') {
        item.dosage = '5 ml'; // or any default value for Syrup
      }
    } else {
      if (item.dosage != '1' && item.dosage != '2' && item.dosage != '3') {
        item.dosage = '1'; // or any default value for Tablet/Capsule
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: item.medicineName),
              onChanged: (value) {
                setState(() {
                  item.medicineName = value;
                });
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                hintText: 'Medicine Name',
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: item.type,
            items: const [
              DropdownMenuItem(value: 'Tablet', child: Text('Tablet')),
              DropdownMenuItem(value: 'Capsule', child: Text('Capsule')),
              DropdownMenuItem(value: 'Syrup', child: Text('Syrup')),
            ],
            onChanged: (value) {
              setState(() {
                item.type = value!;
                item.dosage = value == 'Syrup' ? '5 ml' : '1';
              });

            },
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: item.dosage,
            items: item.type == 'Syrup'
                ? const [
              DropdownMenuItem(value: '5 ml', child: Text('5 ml')),
              DropdownMenuItem(value: '7 ml', child: Text('7 ml')),
              DropdownMenuItem(value: '10 ml', child: Text('10 ml')),
            ]
                : const [
              DropdownMenuItem(value: '1', child: Text('1')),
              DropdownMenuItem(value: '2', child: Text('2')),
              DropdownMenuItem(value: '3', child: Text('3')),
            ],
            onChanged: (value) {
              setState(() {
                item.dosage = value!;
              });

            },
          ),
        ],
      ),
    );
  }
}
