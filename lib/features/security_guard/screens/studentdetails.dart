import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/modal/students.dart';

class StudentDetailForGuard extends StatelessWidget {
  final StudentModal studentData;

  const StudentDetailForGuard({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Image
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          studentData.studentImage != null &&
                              studentData.studentImage!.isNotEmpty
                          ? NetworkImage(studentData.studentImage!)
                          : const AssetImage("assets/images/student.png")
                                as ImageProvider,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Student Info
                  _infoRow("Student Name", studentData.name),
                  _infoRow("Class", studentData.className),
                  _infoRow("Phone", studentData.mobile),
                  _infoRow("Address", studentData.address),
                  _infoRow('College Name', studentData.college_name),

                  const SizedBox(height: 25),

                  // Action Buttons based on current status
                  const SizedBox(height: 25),

                  // BACK BUTTON
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back to Scanner"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
