import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import '../modal/security_guard.dart';
import '../provider/security_guard.dart';

class AddSecurityGuard extends StatefulWidget {
  final int societyId;
  const AddSecurityGuard({super.key, required this.societyId});

  @override
  State<AddSecurityGuard> createState() => _AddSecurityGuardState();
}

class _AddSecurityGuardState extends State<AddSecurityGuard> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? pickedImage;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final idProofCtrl = TextEditingController();

  String? selectedGender;
  bool _isLoading = false;

  // Pick image
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  Future<void> saveGuard() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please fill all required fields correctly", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<SecurityGuardProvider>(
        context,
        listen: false,
      );

      String? imageUrl;

      if (pickedImage != null) {
        imageUrl = await provider.uploadImage(pickedImage!);
        if (imageUrl == null) {
          _showSnackBar("Failed to upload image", Colors.red);
          setState(() => _isLoading = false);
          return;
        }
      }

      final guard = SecurityGuardModal(
        id: 0,
        societyId: widget.societyId,
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        dob: dobCtrl.text.trim(),
        idProof: idProofCtrl.text.trim(),
        gender: selectedGender ?? "",
        profileImage: imageUrl,
        createdAt: DateTime.now().toIso8601String(),
      );

      debugPrint("Attempting to save guard: ${guard.toMap()}");

      final success = await provider.addGuard(guard);

      if (success) {
        _showSnackBar("Security Guard Added Successfully!", Colors.green);
        // Delay navigation to show snackbar
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(
          "Failed to add security guard. Please try again.",
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint("Error in saveGuard: $e");
      _showSnackBar("An error occurred: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    dobCtrl.dispose();
    idProofCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: reuseAppBar(title: "Add Security Guard"),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileSection(),
                const SizedBox(height: 20),
                _buildFormCard(),
                const SizedBox(height: 25),
                _buildSaveButton(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            radius: 65,
            backgroundImage: pickedImage != null
                ? FileImage(pickedImage!)
                : null,
            child: pickedImage == null ? Icon(Icons.person, size: 65) : null,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _isLoading ? null : pickImage,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: _isLoading ? Colors.grey.shade200 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: _isLoading ? Colors.grey : Color(0xFF4286F4),
                ),
                const SizedBox(width: 6),
                Text(
                  "Upload Photo",
                  style: TextStyle(
                    color: _isLoading ? Colors.grey : Color(0xFF4286F4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _inputField(
                controller: nameCtrl,
                label: "Guard Name",
                icon: Icons.person,
                enabled: !_isLoading,
                validator: (v) => v!.isEmpty ? "Enter guard name" : null,
              ),

              _inputField(
                controller: phoneCtrl,
                label: "Phone Number",
                icon: Icons.phone,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v!.isEmpty) return "Enter phone number";
                  if (v.length != 10) return "Phone must be 10 digits";
                  if (!RegExp(r'^[0-9]+$').hasMatch(v))
                    return "Only numbers allowed";
                  return null;
                },
              ),

              _inputField(
                controller: addressCtrl,
                label: "Address",
                icon: Icons.location_on,
                enabled: !_isLoading,
                validator: (v) => v!.isEmpty ? "Enter address" : null,
              ),

              _dobPickerField(),

              _inputField(
                controller: idProofCtrl,
                label: "Adhaar Card Number",
                icon: Icons.badge,
                enabled: !_isLoading,
                validator: (v) => v!.isEmpty ? "Enter ID Proof Number" : null,
              ),

              _genderDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: enabled ? Color(0xFF4286F4) : Colors.grey,
          ),
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF4286F4)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        items: const [
          DropdownMenuItem(value: "Male", child: Text("Male")),
          DropdownMenuItem(value: "Female", child: Text("Female")),
          DropdownMenuItem(value: "Other", child: Text("Other")),
        ],
        onChanged: _isLoading
            ? null
            : (value) {
                setState(() => selectedGender = value);
              },
        decoration: InputDecoration(
          labelText: "Gender",
          prefixIcon: const Icon(Icons.people),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        validator: (v) => v == null ? "Select gender" : null,
      ),
    );
  }

  Widget _dobPickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: dobCtrl,
        readOnly: true,
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            initialDate: DateTime(2000),
          );
          if (picked != null) {
            dobCtrl.text = "${picked.year}-${picked.month}-${picked.day}";
          }
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today),
          labelText: "Date of Birth",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        validator: (v) => v!.isEmpty ? "Select DOB" : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : saveGuard,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isLoading ? Colors.grey : Colors.blue,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Text(
              "Add Guard",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
    );
  }
}
