import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_clone/features/members/providers/guest.dart';
import 'package:provider/provider.dart';

class GuestRequestDetailForGuard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const GuestRequestDetailForGuard({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RequestProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Guest Request Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          requestData['guest_image'] != null &&
                              requestData['guest_image'] != ""
                          ? NetworkImage(requestData['guest_image'])
                          : const AssetImage("assets/images/guest.png")
                                as ImageProvider,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Guest Info
                  infoRow("Guest Name", requestData['guest_name']),
                  infoRow('Relative', requestData['member_name']),
                  infoRow("Phone", requestData['guest_phone']),
                  infoRow("Address", requestData['guest_address'] ?? "N/A"),
                  infoRow("Relation", requestData['request_type']),
                  infoRow("Status", requestData['status']),

                  infoRow(
                    "Created At",
                    requestData['created_at'] != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(
                            DateTime.tryParse(requestData['created_at']) ??
                                DateTime.now(),
                          )
                        : "N/A",
                  ),

                  const SizedBox(height: 25),

                  if (requestData['status'] == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await provider.updateStatus(
                                status: "approved",
                                id: requestData['id'],
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Request Approved"),
                                ),
                              );

                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Approve"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              minimumSize: const Size.fromHeight(45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await provider.updateStatus(
                                status: "rejected",
                                id: requestData['id'],
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Request Rejected"),
                                ),
                              );

                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            label: const Text("Reject"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              minimumSize: const Size.fromHeight(45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Center(
                      child: Text(
                        "This request is already ${requestData['status']}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  // BACK BUTTON
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
