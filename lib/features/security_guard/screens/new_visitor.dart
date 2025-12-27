import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_clone/features/owner/modal/members_modal.dart';
import 'package:my_gate_clone/features/owner/provider/members_provider.dart';
import 'package:my_gate_clone/features/security_guard/modal/visitors.dart';
import 'package:my_gate_clone/features/security_guard/providers/visitor.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class AddVisitorScreen extends StatefulWidget {
  final int societyId;
  final int guardId;

  const AddVisitorScreen({
    super.key,
    required this.guardId,
    required this.societyId,
  });

  @override
  State<AddVisitorScreen> createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController purposeCtrl = TextEditingController();
  final TextEditingController flatCtrl = TextEditingController();
  final TextEditingController idProofCtrl = TextEditingController();
  final TextEditingController vehicleCtrl = TextEditingController();
  final TextEditingController relativeCtrl = TextEditingController();

  String status = "pending";
  MembersModal? selectedMember;

  File? pickedImage;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<MembersProvider>(
      context,
      listen: false,
    ).fatchMembersList(widget.societyId);
  }

  @override
  Widget build(BuildContext context) {
    final membersProvider = Provider.of<MembersProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: 'Add Visitor'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inputField("Name", nameCtrl),
                _inputField("Phone", phoneCtrl, keyboard: TextInputType.phone),
                _inputField("Purpose", purposeCtrl),
                _inputField("Flat No", flatCtrl),
                _inputField("ID Proof", idProofCtrl),
                _inputField("Vehicle No", vehicleCtrl),
                _inputField("Relative Name", relativeCtrl),

                const SizedBox(height: 20),

                membersProvider.isLoading
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<MembersModal>(
                        decoration: const InputDecoration(
                          labelText: "Select Member",
                        ),
                        items: membersProvider.members.map((member) {
                          return DropdownMenuItem(
                            value: member,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(member.memberName),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.home,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                Text(
                                  member.memberFlatNo,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMember = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Please select a member" : null,
                      ),

                const SizedBox(height: 20),

                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: "Status"),
                  value: status,
                  items: const [
                    DropdownMenuItem(value: "pending", child: Text("Pending")),
                    DropdownMenuItem(
                      value: "approved",
                      child: Text("Approved"),
                    ),
                    DropdownMenuItem(
                      value: "rejected",
                      child: Text("Rejected"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => status = value!);
                  },
                ),

                const SizedBox(height: 25),

                const Text(
                  "Visitor Photo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                pickedImage == null
                    ? Container(
                        height: 140,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          pickedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture Visitor Image"),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedMember != null) {
                        final visitor = VisitorModal(
                          id: 0,
                          name: nameCtrl.text,
                          phone: phoneCtrl.text,
                          purpose: purposeCtrl.text,
                          flatNo: flatCtrl.text,
                          idProof: idProofCtrl.text,
                          vehicleNo: vehicleCtrl.text,
                          status: status,
                          relative: relativeCtrl.text,
                          societyId: widget.societyId,
                          memberId: selectedMember!.id,
                          guardId: widget.guardId,
                          image: null,
                          createdAt: DateTime.now(), // Provider will upload
                        );

                        await Provider.of<VisitorProvider>(
                          context,
                          listen: false,
                        ).addVisitor(visitor, pickedImage?.path);

                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Submit Visitor Request"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }
}
