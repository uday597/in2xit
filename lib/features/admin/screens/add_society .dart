import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/admin/screens/societies.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import '../provider/society_provider.dart';
import '../modal/society.dart';

class SocietyScreen extends StatefulWidget {
  const SocietyScreen({super.key});

  @override
  State<SocietyScreen> createState() => _SocietyScreenState();
}

class _SocietyScreenState extends State<SocietyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController collegeNameCrtl = TextEditingController();
  final TextEditingController collegeOwnerCrtl = TextEditingController();
  final TextEditingController collegeOwnerPhoneCrtl = TextEditingController();
  final TextEditingController collegePasswordCrtl = TextEditingController();
  final TextEditingController collegeEmailCrtl = TextEditingController();
  final TextEditingController collegeAddressCrtl = TextEditingController();
  final TextEditingController pincodeCrtl = TextEditingController();
  final TextEditingController cityCrtl = TextEditingController();
  final TextEditingController stateCrtl = TextEditingController();
  final TextEditingController flatsCrtl = TextEditingController();
  final TextEditingController towersCrtl = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocietyProvider>(context, listen: false).fetchSocieties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocietyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: 'Societies'),

      floatingActionButton: provider.societies.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: Colors.lightBlueAccent,
              onPressed: () => openCreateSocietyPopup(context, provider),
              label: const Text(
                "Create Society",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: provider.societies.isNotEmpty
          ? buildSocietyList(provider)
          : buildAddSocietyForm(provider),
    );
  }

  Widget buildSocietyList(SocietyProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: provider.societies.length,
        itemBuilder: (context, index) {
          final society = provider.societies[index];

          return Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                society.collegeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Owner: ${society.ownerName}\nPhone: ${society.ownerPhone}",
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SocietyDetailsScreen(society: society),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildAddSocietyForm(SocietyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Create Society",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          buildFormFields(),

          const SizedBox(height: 30),
          buildCreateButton(provider),
        ],
      ),
    );
  }

  void openCreateSocietyPopup(BuildContext context, SocietyProvider provider) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const Text(
                  "Create New Society",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                buildFormFields(),
                const SizedBox(height: 20),

                buildCreateButton(provider),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildTextField(
            controller: collegeNameCrtl,
            label: 'College Name',
            validator: (v) => v!.isEmpty ? "Enter society name" : null,
          ),
          buildTextField(
            controller: collegePasswordCrtl,
            label: 'Set Password',
            obscure: true,
            validator: (v) => v!.isEmpty ? "Enter password" : null,
          ),
          buildTextField(
            controller: collegeOwnerCrtl,
            label: 'Owner Name',
            validator: (v) => v!.isEmpty ? "Enter owner name" : null,
          ),
          buildTextField(
            controller: collegeOwnerPhoneCrtl,
            label: 'Owner Phone',
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? "Enter owner phone" : null,
          ),
          buildTextField(
            controller: collegeEmailCrtl,
            label: 'Owner Email',
            keyboardType: TextInputType.emailAddress,
          ),
          buildTextField(
            controller: pincodeCrtl,
            label: 'Pincode',
            keyboardType: TextInputType.phone,

            validator: (v) => v!.isEmpty ? "Enter pincode" : null,
          ),
          buildTextField(
            controller: cityCrtl,
            label: 'City',
            validator: (v) => v!.isEmpty ? "Enter city name" : null,
          ),
          buildTextField(
            controller: stateCrtl,
            label: 'State',
            validator: (v) => v!.isEmpty ? "Enter state name" : null,
          ),
          buildTextField(
            controller: towersCrtl,
            label: 'Total Towers',
            keyboardType: TextInputType.phone,

            validator: (v) => v!.isEmpty ? "Enter total towers" : null,
          ),
          buildTextField(
            controller: flatsCrtl,
            label: 'Total Flats',
            keyboardType: TextInputType.phone,

            validator: (v) => v!.isEmpty ? "Enter total flats" : null,
          ),
          buildTextField(
            controller: collegeAddressCrtl,
            label: 'College Address',

            validator: (v) => v!.isEmpty ? "Enter address" : null,
          ),
        ],
      ),
    );
  }

  Widget buildCreateButton(SocietyProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => isLoading = true);

                  final society = CollegeModal(
                    id: 0,
                    collegeName: collegeNameCrtl.text,
                    pincode: pincodeCrtl.text,
                    city: cityCrtl.text,
                    state: stateCrtl.text,
                    total_flats: flatsCrtl.text,
                    total_towers: towersCrtl.text,
                    collegePassword: collegePasswordCrtl.text,
                    ownerName: collegeOwnerCrtl.text,
                    ownerPhone: collegeOwnerPhoneCrtl.text,
                    ownerEmail: collegeEmailCrtl.text,
                    collegeAddress: collegeAddressCrtl.text,
                  );

                  await provider.addSociety(society);
                  await provider.fetchSocieties();
                  pincodeCrtl.clear();
                  cityCrtl.clear();
                  stateCrtl.clear();
                  towersCrtl.clear();
                  flatsCrtl.clear();
                  collegeNameCrtl.clear();
                  collegePasswordCrtl.clear();
                  collegeOwnerCrtl.clear();
                  collegeOwnerPhoneCrtl.clear();
                  collegeEmailCrtl.clear();
                  collegeAddressCrtl.clear();

                  if (Navigator.canPop(context)) Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Society Created Successfully!"),
                    ),
                  );

                  setState(() => isLoading = false);
                }
              },
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Create Society",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool obscure = false,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    ),
  );
}
