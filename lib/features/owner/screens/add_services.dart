import 'package:flutter/material.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import '../modal/service_provider.dart';
import '../provider/service_provider.dart';

class AddProviderScreen extends StatefulWidget {
  final int societyId;
  const AddProviderScreen({super.key, required this.societyId});

  @override
  State<AddProviderScreen> createState() => _AddProviderScreenState();
}

class _AddProviderScreenState extends State<AddProviderScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final chargesCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final timeCtrl = TextEditingController();

  String selectedCategory = "Plumber";
  final categories = ["Plumber", "Electrician", "Carpenter", "Painter"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: reuseAppBar(title: 'Add Service Provider'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _input("Name", nameCtrl),
            _input("Phone", phoneCtrl),
            _input("Address", addressCtrl),
            _input("Experience", experienceCtrl),
            _input("Charges", chargesCtrl),
            _input("Available Time", timeCtrl),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v!),
            ),

            const SizedBox(height: 22),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 40,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blue,
              ),
              onPressed: () async {
                final modal = ServiceProviderModal(
                  id: 0,
                  societyId: widget.societyId,
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                  category: selectedCategory,
                  address: addressCtrl.text,
                  experience: experienceCtrl.text,
                  charges: chargesCtrl.text,
                  availableTime: timeCtrl.text,
                  createdAt: "",
                );

                final ok = await Provider.of<ServiceProviders>(
                  context,
                  listen: false,
                ).addServices(modal);

                if (ok) Navigator.pop(context);
              },
              child: const Text(
                "Add Provider",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String text, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: text,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
