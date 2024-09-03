import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;

class MethodsClass {
  Future<void> checkPermissions() async {
    if (await Permission.storage.request().isGranted) {
      await Permission.storage.request();
    } else {
      // Permission is denied
      // You can show a dialog or redirect the user to the settings page
    }
  }
  void _shareFile(String path) {
    Share.shareFiles([path], text: 'Here is the prescription PDF.');
  }

  Future<void> generateAndSavePrescriptionPDF({
    required String patientName,
    required String mobileNumber,
    String? prescriptionText,
    File? imageFile,
  }) async {
    // Check permissions
    await checkPermissions();

    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/poppins_regular.ttf'));

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Doctor's header at the top
                pw.Text(
                  'Dr. ABC', // Doctor's name
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Phone: XXXXXXXXX98', // Doctor's contact number
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Patient details
                pw.Text('Patient Name: $patientName', style: pw.TextStyle(font: font, fontSize: 14)),
                pw.Text('Mobile Number: $mobileNumber', style: pw.TextStyle(font: font, fontSize: 14)),
                pw.SizedBox(height: 20),

                // Prescription text
                if (prescriptionText != null && prescriptionText.isNotEmpty)
                  pw.Text(prescriptionText, style: pw.TextStyle(font: font, fontSize: 16)),
                if (prescriptionText != null && prescriptionText.isNotEmpty)
                  pw.SizedBox(height: 20),

                // Image (if available)
                if (imageFile != null)
                  pw.Image(
                    pw.MemoryImage(imageFile.readAsBytesSync()),
                    width: 400,
                    height: 400,
                  ),
              ],
            ),
          );
        },
      ),
    );
    final filename = 'prescription_$patientName.pdf';
    final pdfBytes = await pdf.save();
    await _storeFile(filename, pdfBytes);
  }

  Future<File> _storeFile(String filename, List<int> bytes) async {
    late Directory downloadsDirectory;
    try {
      downloadsDirectory = Directory('/storage/emulated/0/Download/doctor_prescription');
      final String path = downloadsDirectory.path;
      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }
      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
        fontSize: 16,
        textColor: Colors.black,
        backgroundColor: Colors.white,
        msg: "Prescription saved at $path",
      );
      final file = File('$path/$filename');
      print(bytes);
      print(file);
      await file.writeAsBytes(bytes, flush: true);
      await Future.delayed(const Duration(seconds: 3));
      _shareFile(file.path.toString());
      return file;
    } catch (e) {
      print('Error storing file: $e');
      Fluttertoast.showToast(
        gravity: ToastGravity.TOP,
        fontSize: 15,
        textColor: Colors.red,
        backgroundColor: Colors.white,
        msg: "Error storing file.",
      );
      rethrow;
    }
  }
}

