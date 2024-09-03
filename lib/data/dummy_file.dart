/*
import 'package:doctor_prescription_app/data/pdf_work.dart';
import 'package:doctor_prescription_app/model/prescription_type_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';


class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  final List<PrescriptionItem> _prescriptions = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _addPrescriptionItem(String medicineName) {
    setState(() {
      _prescriptions.add(
        PrescriptionItem(
          medicineName: medicineName,
          type: 'Tablet', // Default to Tablet
          dosage: '1', // Default dosage
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {

      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speechToText.listen(onResult: (result) {
        setState(() {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {

            final newWords = result.recognizedWords.trim();
            final lastText = _textController.text.trim();

            if (!lastText.endsWith(newWords)) {
              _textController.text += '$newWords\n';
              _addPrescriptionItem(newWords);
              _textController.clear();
            }
          }
        });
      });
    }
  }

  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    _speechToText.stop();
  }

  Future<Map<String, String>?> _showPatientDetailsDialog() async {
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
                  prescriptionText:
                  // _textController.text
                  _prescriptions.map((item) =>
                  '${item.medicineName} (${item.type}) - ${item.dosage}').join('\n'),
                );
                // Validate inputs if necessary
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
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: _prescriptions.length,
              itemBuilder: (context, index) {
                return _buildPrescriptionItem(context, index);
              },
            ),
              TextField(
                focusNode: _focusNode,
              controller: _textController,
              maxLines: null,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
              cursorHeight: 24,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                hintText: 'Write Prescription',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26), // Light grey color
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26), // Slightly darker grey when focused
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red), // Red color when there's an error
                ),
              ),
              onChanged: (text) {
                setState(() {});
              },
                onSubmitted: (text) {
                setState(() {
                  _addPrescriptionItem(text);
                  _textController.clear();
                });
              },
            ),
            const SizedBox(height: 32,),
            if (_textController.text.isNotEmpty ||
                _textController.text.length > 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showPatientDetailsDialog,
                    child: const Text(
                      'Share Prescription',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isListening ? _stopListening : _startListening,
        tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
        label: const Text(
          'Add to Speak',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
  Widget _buildPrescriptionItem(BuildContext context, int index) {
    final item = _prescriptions[index];

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
                contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
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
                item.dosage = value == 'Syrup' ? '5 ml' : '1'; // Update dosage accordingly
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
*/
