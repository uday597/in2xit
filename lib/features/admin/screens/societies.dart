import 'package:flutter/material.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import '../provider/society_provider.dart';
import '../modal/society.dart';

class SocietyDetailsScreen extends StatefulWidget {
  final CollegeModal society;

  const SocietyDetailsScreen({super.key, required this.society});

  @override
  State<SocietyDetailsScreen> createState() => _SocietyDetailsScreenState();
}

class _SocietyDetailsScreenState extends State<SocietyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool isLoading = false;

  late TextEditingController collegeNameCrtl;
  late TextEditingController collegeOwnerCrtl;
  late TextEditingController collegeOwnerPhoneCrtl;
  late TextEditingController collegePasswordCrtl;
  late TextEditingController collegeEmailCrtl;
  late TextEditingController collegeAddressCrtl;
  late TextEditingController pincodeCrtl;
  late TextEditingController cityCrtl;
  late TextEditingController stateCrtl;
  late TextEditingController flatsCrtl;
  late TextEditingController towersCrtl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    collegeNameCrtl = TextEditingController(text: widget.society.collegeName);
    collegePasswordCrtl = TextEditingController(
      text: widget.society.collegePassword,
    );
    collegeOwnerCrtl = TextEditingController(text: widget.society.ownerName);
    collegeOwnerPhoneCrtl = TextEditingController(
      text: widget.society.ownerPhone,
    );
    collegeEmailCrtl = TextEditingController(text: widget.society.ownerEmail);
    collegeAddressCrtl = TextEditingController(
      text: widget.society.collegeAddress,
    );
    pincodeCrtl = TextEditingController(text: widget.society.pincode);
    cityCrtl = TextEditingController(text: widget.society.city);
    stateCrtl = TextEditingController(text: widget.society.state);
    flatsCrtl = TextEditingController(text: widget.society.total_flats);
    towersCrtl = TextEditingController(text: widget.society.total_towers);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocietyProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: 'College Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/gate.png',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // Display or Edit Mode
                if (!_isEditing) ...[
                  // Display Mode - Show society details as text
                  _buildDetailItem('College Name', widget.society.collegeName),
                  _buildDetailItem('Owner Name', widget.society.ownerName),
                  _buildDetailItem('Owner Phone', widget.society.ownerPhone),
                  _buildDetailItem('Owner Email', widget.society.ownerEmail),
                  _buildDetailItem('City', widget.society.city),
                  _buildDetailItem('Pincode', widget.society.pincode),
                  _buildDetailItem('State', widget.society.state),
                  _buildDetailItem('Total Towers', widget.society.total_towers),
                  _buildDetailItem('Total Flats', widget.society.total_flats),
                  _buildDetailItem(
                    'College Address',
                    widget.society.collegeAddress,
                    isMultiline: true,
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons in View Mode
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          child: const Text(
                            "Edit College",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _confirmDelete,
                          child: const Text(
                            "Delete",
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
                ] else ...[
                  // Edit Mode - Show form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(
                          controller: collegeNameCrtl,
                          label: 'College Name',
                          enabled: _isEditing,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter College name'
                              : null,
                        ),
                        buildTextField(
                          controller: collegePasswordCrtl,
                          label: 'Set Password',
                          obscure: true,
                          enabled: _isEditing,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter password' : null,
                        ),
                        buildTextField(
                          controller: collegeOwnerCrtl,
                          label: 'Owner Name',
                          enabled: _isEditing,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter owner name'
                              : null,
                        ),
                        buildTextField(
                          controller: collegeOwnerPhoneCrtl,
                          label: 'Owner Phone',
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter owner phone'
                              : null,
                        ),
                        buildTextField(
                          controller: collegeEmailCrtl,
                          label: 'Owner Email',
                          keyboardType: TextInputType.emailAddress,
                          enabled: _isEditing,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final emailRegex = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              );
                              if (!emailRegex.hasMatch(v))
                                return 'Enter valid email';
                            }
                            return null;
                          },
                        ),
                        buildTextField(
                          controller: cityCrtl,
                          label: 'City',
                          enabled: _isEditing,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter city name' : null,
                        ),
                        buildTextField(
                          controller: pincodeCrtl,
                          label: 'Pincode',
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter pincode' : null,
                        ),
                        buildTextField(
                          controller: stateCrtl,
                          label: 'State',
                          enabled: _isEditing,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter state name'
                              : null,
                        ),
                        buildTextField(
                          controller: towersCrtl,
                          label: 'Total Towers',
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter total towers'
                              : null,
                        ),
                        buildTextField(
                          controller: flatsCrtl,
                          label: 'Total Flats',
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter total flats'
                              : null,
                        ),
                        buildTextField(
                          controller: collegeAddressCrtl,
                          label: 'College Address',
                          enabled: _isEditing,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter College address'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons in Edit Mode
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          await _updateSociety(provider);
                                        }
                                      },
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _isEditing = false;
                                          _initializeControllers();
                                        });
                                      },
                                child: const Text(
                                  "Cancel",
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
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              maxLines: isMultiline ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSociety(SocietyProvider provider) async {
    setState(() => isLoading = true);

    final updatedSociety = CollegeModal(
      id: widget.society.id,
      pincode: pincodeCrtl.text,
      city: cityCrtl.text,
      state: stateCrtl.text,
      total_flats: flatsCrtl.text,
      total_towers: towersCrtl.text,
      collegeName: collegeNameCrtl.text,
      collegePassword: collegePasswordCrtl.text,
      ownerName: collegeOwnerCrtl.text,
      ownerPhone: collegeOwnerPhoneCrtl.text,
      ownerEmail: collegeEmailCrtl.text,
      collegeAddress: collegeAddressCrtl.text,
    );

    try {
      await provider.updateSociety(widget.society.id, updatedSociety);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("College Updated Successfully!")),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this college?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);

      try {
        final provider = Provider.of<SocietyProvider>(context, listen: false);
        await provider.deleteSociety(widget.society.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("College Deleted Successfully!")),
        );

        Navigator.pop(context); // go back
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }

      setState(() => isLoading = false);
    }
  }
}

// Updated reusable text field widget function
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool obscure = false,
  bool enabled = true,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    ),
  );
}
