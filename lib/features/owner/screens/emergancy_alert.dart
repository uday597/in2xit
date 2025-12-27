import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/emergency_alerts.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EmergencyAlertsScreen extends StatefulWidget {
  final int socityId;
  const EmergencyAlertsScreen({super.key, required this.socityId});

  @override
  State<EmergencyAlertsScreen> createState() => _EmergencyAlertsScreenState();
}

class _EmergencyAlertsScreenState extends State<EmergencyAlertsScreen> {
  TextEditingController titleCTRL = TextEditingController();
  TextEditingController descCTRL = TextEditingController();
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmergencyAlertsProvider>(
        context,
        listen: false,
      ).getAlerts(widget.socityId);
    });
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => pickedImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmergencyAlertsProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: 'Emergency Alerts'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Emergency Alert",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // add alert card
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleCTRL,
                        decoration: InputDecoration(
                          labelText: "Alert Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCTRL,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Alert Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (pickedImage != null)
                        Image.file(
                          pickedImage!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Upload Image"),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          if (titleCTRL.text.trim().isEmpty ||
                              descCTRL.text.trim().isEmpty)
                            return;

                          await provider.addAlert(
                            societyId: widget.socityId,
                            title: titleCTRL.text.trim(),
                            description: descCTRL.text.trim(),
                            imageFile: pickedImage,
                          );

                          titleCTRL.clear();
                          descCTRL.clear();
                          pickedImage = null;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Alert Added Successfully"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade500,
                                Colors.red.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              "Add Alert",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
              const Text(
                "Recent Alerts",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 15),

              // list section
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.alerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(25),
                  child: Center(
                    child: Text(
                      "No alerts found.\nCreate your first alert!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.alerts.length,
                  itemBuilder: (context, index) {
                    final a = provider.alerts[index];
                    return Card(
                      color: Colors.white,
                      shadowColor: Colors.grey.shade200,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['title'],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a['description'],
                              style: const TextStyle(fontSize: 15),
                            ),
                            if (a['image'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Image.network(
                                  a['image'],
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _showUpdateDialog(context, a, provider);
                                  },
                                  child: const Text("Update"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await provider.deleteAlert(
                                      a['id'],
                                      widget.socityId,
                                    );
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // update dialog
  void _showUpdateDialog(
    context,
    Map<String, dynamic> alert,
    EmergencyAlertsProvider provider,
  ) {
    TextEditingController titleCtrl = TextEditingController(
      text: alert['title'],
    );
    TextEditingController descCtrl = TextEditingController(
      text: alert['description'],
    );
    File? updateImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future pickUpdateImage() async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null)
                setState(() => updateImage = File(picked.path));
            }

            return AlertDialog(
              title: const Text("Update Alert"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (alert['image'] != null && updateImage == null)
                      Image.network(alert['image'], height: 150),
                    if (updateImage != null)
                      Image.file(updateImage!, height: 150),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: pickUpdateImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Change Image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    await provider.updateAlert(
                      alertId: alert['id'],
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      societyId: widget.socityId,
                      imageFile: updateImage,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
