import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import '../../owner/modal/members_modal.dart';
import '../providers/guest.dart';

class GuestRequestScreen extends StatefulWidget {
  final MembersModal member;
  final String defaultRequestType;
  const GuestRequestScreen({
    super.key,
    required this.member,
    required this.defaultRequestType,
  });

  @override
  State<GuestRequestScreen> createState() => _GuestRequestScreenState();
}

class _GuestRequestScreenState extends State<GuestRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final guestName = TextEditingController();
  final guestPhone = TextEditingController();
  final guestAddress = TextEditingController();

  File? imageFile;

  String selectedRequestType = 'guest';
  List<String> requestTypes = [
    'Guest',
    'Relative',
    'Student',
    'Delivery Boy',
    'Family Member',
  ];

  void initState() {
    super.initState();

    selectedRequestType = widget.defaultRequestType.toLowerCase().replaceAll(
      ' ',
      '_',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RequestProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xfff2f5f7),
      appBar: reuseAppBar(title: 'Add Guest Request'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildAddRequestCard(provider),
        ),
      ),
    );
  }

  Widget _buildAddRequestCard(RequestProvider provider) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(guestName, "Name"),
              const SizedBox(height: 12),
              _buildTextField(
                guestPhone,
                "Phone",
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(guestAddress, "Address"),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRequestType,
                decoration: InputDecoration(
                  labelText: "Request Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: requestTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type.toLowerCase().replaceAll(' ', '_'),
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedRequestType = val!;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: const Text("Person Image"),
                  ),
                  const SizedBox(width: 12),
                  if (imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        imageFile!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => addRequest(provider),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Submit Request",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController c,
    String label, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Enter $label" : null,
    );
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> addRequest(RequestProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await provider.addGuestRequest(
      societyId: widget.member.societyId,
      memberId: widget.member.id,
      guestName: guestName.text,
      guestPhone: guestPhone.text,
      guestAddress: guestAddress.text,
      guestImageFile: imageFile,
      requestType: selectedRequestType,
    );

    if (ok) {
      guestName.clear();
      guestPhone.clear();
      guestAddress.clear();
      imageFile = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request Submitted Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
