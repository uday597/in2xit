import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_clone/features/owner/provider/student.dart';
import 'package:provider/provider.dart';
import '../modal/students.dart';

class Editstdudent extends StatefulWidget {
  final StudentModal student;
  final int collegeId;

  const Editstdudent({
    super.key,
    required this.student,
    required this.collegeId,
  });

  @override
  State<Editstdudent> createState() => _EditstdudentState();
}

class _EditstdudentState extends State<Editstdudent> {
  bool isEditMode = false;
  File? selectedImage;

  late TextEditingController nameCtrl;
  late TextEditingController classCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.student.name);
    classCtrl = TextEditingController(text: widget.student.className);
    mobileCtrl = TextEditingController(text: widget.student.mobile);
    addressCtrl = TextEditingController(text: widget.student.address);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Student Profile"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
                selectedImage = null;
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔵 PROFILE IMAGE
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : widget.student.studentImage != null
                      ? NetworkImage(widget.student.studentImage!)
                      : null,
                  child:
                      widget.student.studentImage == null &&
                          selectedImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),

                if (isEditMode)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            _field("Name", nameCtrl),
            _field("Class", classCtrl),
            _field("Mobile", mobileCtrl),
            _field("Address", addressCtrl, maxLines: 3),

            const SizedBox(height: 20),

            if (isEditMode)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await provider.updateStudent(
                      id: widget.student.id,
                      collegeId: widget.collegeId,
                      name: nameCtrl.text,
                      className: classCtrl.text,
                      mobile: mobileCtrl.text,
                      address: addressCtrl.text,
                      imageFile: selectedImage,
                    );

                    setState(() {
                      isEditMode = false;
                      selectedImage = null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Student Updated")),
                    );
                  },
                  child: const Text("Save Changes"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: isEditMode,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: !isEditMode,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
