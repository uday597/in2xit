import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/providers/complaints.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class ComplaintsRequests extends StatefulWidget {
  final int socityId;
  const ComplaintsRequests({super.key, required this.socityId});

  @override
  State<ComplaintsRequests> createState() => _ComplaintsRequestsState();
}

class _ComplaintsRequestsState extends State<ComplaintsRequests> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ComplaintsProvider>(
        context,
        listen: false,
      ).fetchcomplaintsRequests(widget.socityId);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintsProvider>(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.complaints.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: reuseAppBar(title: 'Complaints Requests'),
        body: const Center(child: Text("No complaints found.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: 'Complaints Requests'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.complaints.length,
        itemBuilder: (context, index) {
          final c = provider.complaints[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: c.memberImage != null
                          ? NetworkImage(c.memberImage!)
                          : null,
                      child: c.memberImage == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.memberName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${c.memberPhone ?? ""} | Flat ${c.flatNo ?? ""}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Complaint Title
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Complaint Description
                Text(
                  c.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),

                const SizedBox(height: 8),

                // Complaint Image if available
                if (c.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      c.image!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 8),

                // Date and Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Submitted on ${c.createdAt.toLocal().toString().substring(0, 16)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                              "Are you sure you want to delete this complaint?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && c.id != null) {
                          await provider.deleteComplaint(c.id!);
                          setState(() {}); // Refresh UI after delete
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
