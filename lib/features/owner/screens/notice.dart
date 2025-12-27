import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/notice.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class Notice extends StatefulWidget {
  final int socityId;
  const Notice({super.key, required this.socityId});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  TextEditingController noticeCRTL = TextEditingController();
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    Provider.of<NoticeProvider>(
      context,
      listen: false,
    ).getNotices(widget.socityId);
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => pickedImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoticeProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: 'Notice Board'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New Notice",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
                        controller: noticeCRTL,
                        maxLines: 5,
                        decoration: InputDecoration(
                          label: const Text("Write your notice..."),
                          hintText: "Example: Water supply off at 3 PM.",
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
                          if (noticeCRTL.text.trim().isEmpty) return;

                          await provider.addNotice(
                            societyId: widget.socityId,
                            notice: noticeCRTL.text.trim(),
                            imageFile: pickedImage,
                          );

                          noticeCRTL.clear();
                          pickedImage = null;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Notice Added Successfully"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade500,
                                Colors.blue.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              "Add Notice",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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
                "Recent Notices",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 15),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.notices.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text(
                      "No notices found.\nAdd your first notice!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.notices.length,
                  itemBuilder: (context, index) {
                    final n = provider.notices[index];
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['notice'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (n['image'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Image.network(
                                  n['image'],
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
                                    _showUpdateDialog(context, n, provider);
                                  },
                                  child: const Text(
                                    "Update",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await provider.deleteNotice(
                                      n['id'],
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

  void _showUpdateDialog(
    context,
    Map<String, dynamic> notice,
    NoticeProvider provider,
  ) {
    TextEditingController updateCtrl = TextEditingController(
      text: notice['notice'],
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
              title: const Text("Update Notice"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: updateCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (notice['image'] != null && updateImage == null)
                      Image.network(
                        notice['image'],
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    if (updateImage != null)
                      Image.file(updateImage!, height: 150, fit: BoxFit.cover),
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
                    await provider.updateNotice(
                      noticeId: notice['id'],
                      noticeText: updateCtrl.text.trim(),
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
