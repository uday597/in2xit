import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/security_guard/providers/visitor.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class MemberVisitorsScreen extends StatefulWidget {
  final int memberId;

  const MemberVisitorsScreen({super.key, required this.memberId});

  @override
  State<MemberVisitorsScreen> createState() => _MemberVisitorsScreenState();
}

class _MemberVisitorsScreenState extends State<MemberVisitorsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<VisitorProvider>(
      context,
      listen: false,
    ).fetchVisitorsForMember(widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VisitorProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: "Visitor Requests"),
      backgroundColor: Colors.white,
      body: provider.visitorList.isEmpty
          ? const Center(
              child: Text(
                "No visitor requests found",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: provider.visitorList.length,
              itemBuilder: (context, index) {
                final visitor = provider.visitorList[index];

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              visitor.image != null && visitor.image!.isNotEmpty
                              ? Image.network(
                                  visitor.image!,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 70,
                                  width: 70,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.black54,
                                  ),
                                ),
                        ),

                        const SizedBox(width: 12),

                        // DETAILS + BUTTONS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visitor.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("Phone: ${visitor.phone}"),
                              Text("Purpose: ${visitor.purpose}"),
                              Text("Vehicle: ${visitor.vehicleNo}"),

                              const SizedBox(height: 10),

                              // STATUS
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _statusBadge(visitor.status),
                              ),

                              const SizedBox(height: 10),

                              if (visitor.status == "pending")
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          provider.updateVisitorStatus(
                                            visitor.id,
                                            "approved",
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text(
                                          "Approve",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          provider.updateVisitorStatus(
                                            visitor.id,
                                            "rejected",
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          "Reject",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "approved":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
