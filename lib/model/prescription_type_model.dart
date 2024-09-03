class PrescriptionItem {
  String medicineName;
  String type; // 'Tablet', 'Capsule', 'Syrup'
  String dosage;

  PrescriptionItem({
    required this.medicineName,
    required this.type,
    required this.dosage,
  });
}
