import 'package:flutter/material.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import '../modal/service_provider.dart';
import '../provider/service_provider.dart';

class ViewProviderScreen extends StatefulWidget {
  final ServiceProviderModal provider;

  const ViewProviderScreen({super.key, required this.provider});

  @override
  State<ViewProviderScreen> createState() => _ViewProviderScreenState();
}

class _ViewProviderScreenState extends State<ViewProviderScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController chargesCtrl;
  late TextEditingController experienceCtrl;
  late TextEditingController timeCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.provider.name);
    phoneCtrl = TextEditingController(text: widget.provider.phone);
    addressCtrl = TextEditingController(text: widget.provider.address);
    chargesCtrl = TextEditingController(text: widget.provider.charges);
    experienceCtrl = TextEditingController(text: widget.provider.experience);
    timeCtrl = TextEditingController(text: widget.provider.availableTime);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProviders>(context);

    return Scaffold(
      appBar: reuseAppBar(title: widget.provider.name),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildInput("Name", nameCtrl),
            _buildInput("Phone", phoneCtrl),
            _buildInput("Address", addressCtrl),
            _buildInput("Experience", experienceCtrl),
            _buildInput("Charges", chargesCtrl),
            _buildInput("Available Time", timeCtrl),

            const SizedBox(height: 25),

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
                final updated = {
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text,
                  'address': addressCtrl.text,
                  'experience': experienceCtrl.text,
                  'charges': chargesCtrl.text,
                  'available_time': timeCtrl.text,
                };

                bool ok = await provider.updateProvider(
                  widget.provider.id,
                  updated,
                  widget.provider.societyId,
                );

                if (ok) Navigator.pop(context);
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 40,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                bool ok = await provider.deleteProvider(widget.provider.id);
                if (ok) Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
