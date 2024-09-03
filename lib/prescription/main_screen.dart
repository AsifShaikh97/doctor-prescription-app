import 'package:doctor_prescription_app/data/pdf_work.dart';
import 'package:doctor_prescription_app/prescription/prescription_screen.dart';
import 'package:doctor_prescription_app/prescription/upload_prescription_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    MethodsClass().checkPermissions();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Write Prescription'),
            Tab(text: 'Upload Prescription'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PrescriptionScreen(),
          UploadPrescription(),
        ],
      ),
    );
  }
}
