import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/student.dart';
import 'package:my_gate_clone/features/owner/screens/editStdudent.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AllStudents extends StatefulWidget {
  final int collegeId;
  const AllStudents({super.key, required this.collegeId});

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  String searchName = '';
  String? selectedClass;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(
        context,
        listen: false,
      ).fetchStudents(widget.collegeId);
    });
  }

  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final students = provider.students.where((student) {
      final matchName = student.name.toLowerCase().contains(
        searchName.toLowerCase(),
      );

      final matchClass =
          selectedClass == null ||
          selectedClass!.isEmpty ||
          student.className == selectedClass;

      return matchName && matchClass;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: 'All Students'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// SEARCH BY NAME
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search by student name",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchName = value;
                    });
                  },
                ),

                const SizedBox(height: 10),

                /// FILTER BY CLASS
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: InputDecoration(
                    hintText: "All Class/Course",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Classes'),
                    ),
                    ...provider.students
                        .map((e) => e.className)
                        .toSet()
                        .map(
                          (className) => DropdownMenuItem<String>(
                            value: className,
                            child: Text(className),
                          ),
                        )
                        .toList(),
                  ],

                  onChanged: (value) {
                    setState(() {
                      selectedClass = value;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: students.isEmpty
                ? Center(child: Text('No Students'))
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Editstdudent(
                                student: student,
                                collegeId: widget.collegeId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.grey.shade100,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.blue.shade100,
                                  backgroundImage: student.studentImage != null
                                      ? NetworkImage(student.studentImage!)
                                      : null,
                                  child: student.studentImage == null
                                      ? const Icon(Icons.person, size: 28)
                                      : null,
                                ),

                                const SizedBox(width: 12),

                                /// NAME + CLASS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${student.name}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Class/Course: ${student.className}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        'Address: ${student.address}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        'Mobile: ${student.mobile}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// QR BUTTON
                                InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    if (student.qrCode == null ||
                                        student.qrCode!.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "QR code not available",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    _showQrDialog(context, student.qrCode!);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, String qrData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Student QR Code", textAlign: TextAlign.center),
          content: SizedBox(
            width: 250, // ⭐ IMPORTANT
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(data: qrData, size: 180),
                const SizedBox(height: 12),
                const Text(
                  "Scan this QR at the gate",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
