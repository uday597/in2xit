import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:my_gate_clone/features/owner/modal/members_modal.dart';
import 'package:my_gate_clone/features/owner/provider/members_provider.dart';

class EditMemberInfo extends StatefulWidget {
  final int memberId;
  const EditMemberInfo({super.key, required this.memberId});

  @override
  State<EditMemberInfo> createState() => _EditMemberInfoState();
}

class _EditMemberInfoState extends State<EditMemberInfo> {
  MembersModal? member;
  final _formKey = GlobalKey<FormState>();

  final picker = ImagePicker();
  File? pickedImageFile;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController flatController;
  late TextEditingController towerController;
  late TextEditingController dobController;
  late TextEditingController totalVehicleController;
  late TextEditingController vehicleNoController;
  late TextEditingController idProofController;

  String selectedGender = "Male";

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<MembersProvider>(context, listen: false);
    member = provider.members.firstWhere((m) => m.id == widget.memberId);

    // Initialize controllers with existing values
    nameController = TextEditingController(text: member!.memberName);
    emailController = TextEditingController(text: member!.memberEmail);
    phoneController = TextEditingController(text: member!.memberPhone);
    addressController = TextEditingController(text: member!.memberAddress);
    flatController = TextEditingController(text: member!.memberFlatNo);
    towerController = TextEditingController(text: member!.tower);
    dobController = TextEditingController(text: member!.dob);
    totalVehicleController = TextEditingController(text: member!.totalVehicle);
    vehicleNoController = TextEditingController(text: member!.vehicleNo);
    idProofController = TextEditingController(text: member!.idProof);

    selectedGender = member!.gender;
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImageFile = File(picked.path);
      });
    }
  }

  Future<void> updateMember() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<MembersProvider>(context, listen: false);

    String? imageUrl = member!.memberImage;

    // Upload new image if picked
    if (pickedImageFile != null) {
      final uploadedUrl = await provider.uploadImage(pickedImageFile!);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    final updatedMember = MembersModal(
      id: member!.id,
      societyId: member!.societyId,
      memberName: nameController.text.trim(),
      memberEmail: emailController.text.trim(),
      memberPhone: phoneController.text.trim(),
      memberAddress: addressController.text.trim(),
      memberFlatNo: flatController.text.trim(),
      memberImage: imageUrl,
      tower: towerController.text.trim(),
      gender: selectedGender,
      dob: dobController.text.trim(),
      totalVehicle: totalVehicleController.text.trim(),
      vehicleNo: vehicleNoController.text.trim(),
      idProof: idProofController.text.trim(),
    );

    await provider.updateMember(updatedMember, updatedMember);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Member updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: "Edit Member"),
      body: member == null
          ? const Center(child: Text("Member not found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundImage: pickedImageFile != null
                                  ? FileImage(pickedImageFile!)
                                  : (member!.memberImage != null &&
                                        member!.memberImage!.isNotEmpty &&
                                        member!.memberImage!.startsWith("http"))
                                  ? NetworkImage(member!.memberImage!)
                                  : const AssetImage(
                                          "assets/default_avatar.png",
                                        )
                                        as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: pickImage,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade50,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Color(0xFF4286F4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Form Card
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            buildInputField(
                              controller: nameController,
                              label: "Full Name",
                              icon: Icons.person,
                              validator: (v) =>
                                  v!.isEmpty ? "Enter full name" : null,
                            ),

                            buildInputField(
                              controller: emailController,
                              label: "Email",
                              icon: Icons.email,
                            ),

                            buildInputField(
                              controller: phoneController,
                              label: "Phone Number",
                              icon: Icons.phone,
                            ),

                            buildInputField(
                              controller: addressController,
                              label: "Address",
                              icon: Icons.location_on,
                            ),

                            buildInputField(
                              controller: flatController,
                              label: "Flat Number",
                              icon: Icons.home,
                              validator: (v) =>
                                  v!.isEmpty ? "Flat number required" : null,
                            ),
                            // Tower
                            buildInputField(
                              controller: towerController,
                              label: "Tower / Block",
                              icon: Icons.apartment,
                              validator: (v) =>
                                  v!.isEmpty ? "Enter tower name" : null,
                            ),

                            // Gender Dropdown
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: DropdownButtonFormField<String>(
                                value: selectedGender,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF4286F4),
                                  ),
                                  labelText: "Gender",
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: ["Male", "Female", "Other"]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => selectedGender = v!),
                              ),
                            ),

                            // DOB with date picker
                            InkWell(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now(),
                                );

                                if (pickedDate != null) {
                                  dobController.text =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                  setState(() {});
                                }
                              },
                              child: IgnorePointer(
                                child: buildInputField(
                                  controller: dobController,
                                  label: "Date of Birth",
                                  icon: Icons.calendar_month,
                                  validator: (v) =>
                                      v!.isEmpty ? "Enter DOB" : null,
                                ),
                              ),
                            ),

                            // Total Vehicles
                            buildInputField(
                              controller: totalVehicleController,
                              label: "Total Vehicles",
                              icon: Icons.directions_car_outlined,
                              validator: (v) => v!.isEmpty
                                  ? "Enter number of vehicles"
                                  : null,
                            ),

                            // Vehicle Number
                            buildInputField(
                              controller: vehicleNoController,
                              label: "Vehicle Number",
                              icon: Icons.confirmation_number,
                              validator: (v) =>
                                  v!.isEmpty ? "Enter vehicle number" : null,
                            ),

                            // ID Proof
                            buildInputField(
                              controller: idProofController,
                              label: "ID Proof (Aadhar / PAN / Passport)",
                              icon: Icons.badge,
                              validator: (v) =>
                                  v!.isEmpty ? "Enter ID proof" : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: updateMember,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Color(0xFF4286F4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              "Update",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  title: const Text(
                                    "Delete Member",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                    "Are you sure you want to delete this member?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final provider =
                                            Provider.of<MembersProvider>(
                                              context,
                                              listen: false,
                                            );

                                        await provider.deleteSociety(
                                          member!.id,
                                        );

                                        Navigator.pop(context); // close dialog
                                        Navigator.pop(context); // go back

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Member deleted successfully",
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
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

  // Reusable TextField widget
  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 15),
          filled: true,
          fillColor: Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
