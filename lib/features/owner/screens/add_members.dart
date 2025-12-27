import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import '../provider/members_provider.dart';
import '../modal/members_modal.dart';

class AddMembers extends StatefulWidget {
  final int ownerID;
  const AddMembers({super.key, required this.ownerID});

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final flatController = TextEditingController();
  final towerController = TextEditingController();
  final dobController = TextEditingController();
  final totalVehicleController = TextEditingController();
  final vehicleNoController = TextEditingController();
  final idProofController = TextEditingController();

  String gender = "Male";

  File? pickedImage;
  final picker = ImagePicker();

  Future pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        pickedImage = File(file.path);
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    flatController.dispose();
    towerController.dispose();
    dobController.dispose();
    totalVehicleController.dispose();
    vehicleNoController.dispose();
    idProofController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersProvider = Provider.of<MembersProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: 'Add Members'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF4286F4),
                  backgroundImage: pickedImage != null
                      ? FileImage(pickedImage!)
                      : null,
                  child: pickedImage == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 25),

              buildTextFormField(
                controller: nameController,
                label: "Member Name",
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter member name";
                  }
                  return null;
                },
              ),
              buildTextFormField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter email";
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              buildTextFormField(
                controller: phoneController,
                label: "Phone",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter phone number";
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return "Enter a valid 10-digit phone number";
                  }
                  return null;
                },
              ),
              buildTextFormField(
                controller: addressController,
                label: "Address",
                icon: Icons.home,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter address";
                  }
                  return null;
                },
              ),
              buildTextFormField(
                controller: flatController,
                label: "Flat No.",
                icon: Icons.apartment,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter flat number";
                  }
                  return null;
                },
              ),
              // TOWER
              buildTextFormField(
                controller: towerController,
                label: "Tower / Block",
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter tower name";
                  }
                  return null;
                },
              ),

              // GENDER DROPDOWN
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: gender,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF4286F4),
                    ),
                    labelText: "Gender",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ["Male", "Female", "Other"]
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => setState(() => gender = value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select gender";
                    }
                    return null;
                  },
                ),
              ),

              // DOB
              buildTextFormField(
                controller: dobController,
                label: "Date of Birth (DD/MM/YYYY)",
                icon: Icons.calendar_month,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter DOB";
                  }
                  return null;
                },
              ),

              // TOTAL VEHICLES
              buildTextFormField(
                controller: totalVehicleController,
                label: "Total Vehicles",
                icon: Icons.directions_car_filled,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter number of vehicles";
                  }
                  return null;
                },
              ),

              // VEHICLE NUMBER
              buildTextFormField(
                controller: vehicleNoController,
                label: "Vehicle Number",
                icon: Icons.numbers,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter vehicle number";
                  }
                  return null;
                },
              ),

              // ID PROOF
              buildTextFormField(
                controller: idProofController,
                label: "ID Proof (Aadhar/PAN/etc.)",
                icon: Icons.badge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter ID proof";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4286F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Color(0xFF4286F4)),
                  label: const Text(
                    "Add Member",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (pickedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please pick an image first!"),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Upload image
                    String? imageName = await membersProvider.uploadImage(
                      pickedImage!,
                    );

                    if (imageName == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Image upload failed!"),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Create Member Model
                    MembersModal newMember = MembersModal(
                      id: 0,
                      societyId: widget.ownerID,
                      memberName: nameController.text.trim(),
                      memberEmail: emailController.text.trim(),
                      memberPhone: phoneController.text.trim(),
                      memberAddress: addressController.text.trim(),
                      memberFlatNo: flatController.text.trim(),
                      memberImage: imageName,
                      tower: towerController.text.trim(),
                      gender: gender,
                      dob: dobController.text.trim(),
                      totalVehicle: totalVehicleController.text.trim(),
                      vehicleNo: vehicleNoController.text.trim(),
                      idProof: idProofController.text.trim(),
                    );

                    await membersProvider.addMembers(newMember);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Member added successfully!"),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextFormField with validation
  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF4286F4)),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
