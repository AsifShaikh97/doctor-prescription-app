import 'package:doctor_prescription_app/model/prescription_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PrescriptionController extends GetxController {
  final SpeechToText speechToText = SpeechToText();
  var isListening = false.obs;
  var prescriptions = <PrescriptionItem>[].obs;
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        // Handle focus loss if necessary
      }
    });
  }

  void addPrescriptionItem(String medicineName) {
    prescriptions.add(
      PrescriptionItem(
        medicineName: medicineName,
        type: 'Tablet', // Default to Tablet
        dosage: '1', // Default dosage
      ),
    );
  }

  void startListening() async {
    bool available = await speechToText.initialize();
    if (available) {
      isListening.value = true;
      speechToText.listen(onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          final newWords = result.recognizedWords.trim();
          final lastText = textController.text.trim();

          if (!lastText.endsWith(newWords)) {
            textController.text += '$newWords\n';
            addPrescriptionItem(newWords);
            textController.clear();
          }
        }
      });
    }
  }

  void stopListening() {
    isListening.value = false;
    speechToText.stop();
  }

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
