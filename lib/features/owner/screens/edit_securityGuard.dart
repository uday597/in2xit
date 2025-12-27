import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_clone/features/owner/modal/security_guard.dart';
import 'package:my_gate_clone/features/owner/provider/security_guard.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class EditSecurityGuardScreen extends StatefulWidget {
  final SecurityGuardModal guard;

  const EditSecurityGuardScreen({super.key, required this.guard});

  @override
  State<EditSecurityGuardScreen> createState() =>
      _EditSecurityGuardScreenState();
}

class _EditSecurityGuardScreenState extends State<EditSecurityGuardScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dobController;
  late TextEditingController idProofController;

  String? selectedGender;

  File? pickedImageFile;
  bool isUpdating = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.guard.name);
    phoneController = TextEditingController(text: widget.guard.phone);
    addressController = TextEditingController(text: widget.guard.address);

    dobController = TextEditingController(text: widget.guard.dob);
    idProofController = TextEditingController(text: widget.guard.idProof);

    selectedGender = widget.guard.gender;
  }

  Future pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        pickedImageFile = File(file.path);
      });
    }
  }

  Future updateGuard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUpdating = true);

    final provider = Provider.of<SecurityGuardProvider>(context, listen: false);

    String? newImageUrl;

    if (pickedImageFile != null) {
      newImageUrl = await provider.uploadImage(pickedImageFile!);
    }

    final updatedGuard = SecurityGuardModal(
      id: widget.guard.id,
      societyId: widget.guard.societyId,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      dob: dobController.text.trim(),
      idProof: idProofController.text.trim(),
      gender: selectedGender ?? "",
      profileImage: newImageUrl ?? widget.guard.profileImage,
      createdAt: widget.guard.createdAt,
    );

    final success = await provider.updateGuard(updatedGuard);

    setState(() => isUpdating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Guard Updated Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Update Failed")));
    }
  }

  Future<void> deleteGuard() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Guard"),
        content: const Text(
          "Are you sure you want to delete this security guard? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isDeleting = true);

    final provider = Provider.of<SecurityGuardProvider>(context, listen: false);

    final success = await provider.deleteGuard(widget.guard.id);

    setState(() => isDeleting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Guard deleted successfully")),
      );
      Navigator.pop(context); // go back after delete
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete guard")));
    }
  }

  Future selectDob() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime.tryParse(widget.guard.dob) ?? DateTime(2000),
    );

    if (picked != null) {
      dobController.text = "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: reuseAppBar(title: 'Edit Information'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // IMAGE
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: pickedImageFile != null
                      ? FileImage(pickedImageFile!)
                      : (widget.guard.profileImage != null &&
                            widget.guard.profileImage!.startsWith("http"))
                      ? NetworkImage(widget.guard.profileImage!)
                      : const AssetImage("assets/default_avatar.png")
                            as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.edit, size: 18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // NAME
              TextFormField(
                controller: nameController,
                decoration: input("Guard Name"),
                validator: (v) => v!.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 15),

              // PHONE
              TextFormField(
                controller: phoneController,
                decoration: input("Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length != 10 ? "Enter valid number" : null,
              ),
              const SizedBox(height: 15),

              // ADDRESS
              TextFormField(
                controller: addressController,
                decoration: input("Address"),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // DOB
              TextFormField(
                controller: dobController,
                readOnly: true,
                decoration: input(
                  "Date of Birth",
                ).copyWith(suffixIcon: const Icon(Icons.calendar_month)),
                onTap: selectDob,
                validator: (v) => v!.isEmpty ? "Select DOB" : null,
              ),
              const SizedBox(height: 15),

              // ID PROOF
              TextFormField(
                controller: idProofController,
                decoration: input("ID Proof Number"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // GENDER
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: input("Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (value) {
                  setState(() => selectedGender = value);
                },
                validator: (v) => v == null ? "Select gender" : null,
              ),

              const SizedBox(height: 25),

              // UPDATE BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 45,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isUpdating ? null : updateGuard,
                      child: isUpdating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Update",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isDeleting ? null : deleteGuard,
                      child: isDeleting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Delete",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
