import 'dart:io';
import 'package:doctor_prescription_app/data/pdf_work.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class UploadPrescription extends StatefulWidget {
  @override
  _UploadPrescriptionState createState() => _UploadPrescriptionState();
}

class _UploadPrescriptionState extends State<UploadPrescription> {
  XFile? _image;
  String _text = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedImage = await _picker.pickImage(source: source);

    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  Future<Map<String, String>?> _showPatientDetailsDialog() async {

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Patient Details'),
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
                    imageFile:File(_image!.path));
                Navigator.pop(context, {
                  'name': nameController.text,
                  'mobile': mobileController.text,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30,),
          Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: const Text("Upload prescription from gallery or camera",style: TextStyle(fontFamily: 'Poppins',fontSize: 16))),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: GestureDetector(
              onTap: () => _showPicker(context),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [6, 3],
                color: Colors.grey,
                strokeWidth: 2,
                child: const SizedBox(
                  height: 100,
                  width: 100,
                  child: Center(
                    child: Icon(Icons.folder_copy_outlined, size: 32, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          if (_image != null)
            Container(
              margin: const EdgeInsets.all(16),
              height: 250,
              child: Image.file(File(_image!.path)),
            ),
          if (_image != null)
          ElevatedButton(
            onPressed:() {
              _showPatientDetailsDialog();
            },
            child: const Text('Generate PDF'),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
