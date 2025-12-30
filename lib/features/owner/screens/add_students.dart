import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:my_gate_clone/features/owner/provider/student.dart';
import 'package:my_gate_clone/utilis/appbar.dart';

class AddStudents extends StatefulWidget {
  final int collegeId;
  const AddStudents({super.key, required this.collegeId});

  @override
  State<AddStudents> createState() => _AddStudentsState();
}

class _AddStudentsState extends State<AddStudents> {
  final _formKey = GlobalKey<FormState>();

  final nameCrtl = TextEditingController();
  final classCrtl = TextEditingController();
  final addressCrtl = TextEditingController();
  final mobileCrtl = TextEditingController();

  File? pickedImage;

  Future<void> imagePicker() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    nameCrtl.dispose();
    classCrtl.dispose();
    addressCrtl.dispose();
    mobileCrtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: reuseAppBar(title: 'Add Student'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// IMAGE PICKER
              GestureDetector(
                onTap: imagePicker,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: pickedImage != null
                      ? FileImage(pickedImage!)
                      : null,
                  child: pickedImage == null
                      ? const Icon(Icons.camera_alt, size: 32)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              /// CARD FORM
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _field(
                        controller: nameCrtl,
                        label: "Student Name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 12),

                      _field(
                        controller: classCrtl,
                        label: "Class / Course",
                        icon: Icons.school,
                      ),
                      const SizedBox(height: 12),

                      _field(
                        controller: mobileCrtl,
                        label: "Mobile Number",
                        icon: Icons.phone,
                        keyboard: TextInputType.phone,
                        maxLength: 10,
                      ),
                      const SizedBox(height: 12),

                      _field(
                        controller: addressCrtl,
                        label: "Address",
                        icon: Icons.location_on,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          final success = await provider.addStudent(
                            collegeId: widget.collegeId,
                            name: nameCrtl.text.trim(),
                            className: classCrtl.text.trim(),
                            mobile: mobileCrtl.text.trim(),
                            address: addressCrtl.text.trim(),
                            imageFile: pickedImage,
                          );

                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Student Added Successfully"),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Add Student",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TEXTFIELD WIDGET
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: "",
      ),
    );
  }
}
