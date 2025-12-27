import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/emergency_alerts.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MemberEmergencyAlertsList extends StatefulWidget {
  final int societyId;

  const MemberEmergencyAlertsList({super.key, required this.societyId});

  @override
  State<MemberEmergencyAlertsList> createState() =>
      _MemberEmergencyAlertsListState();
}

class _MemberEmergencyAlertsListState extends State<MemberEmergencyAlertsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmergencyAlertsProvider>(
        context,
        listen: false,
      ).getAlerts(widget.societyId);
    });
  }

  String formatDate(String date) {
    final d = DateTime.parse(date);
    return DateFormat('dd MMM, yyyy • hh:mm a').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmergencyAlertsProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: "Emergency Alerts"),
      backgroundColor: Colors.grey.shade100,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.alerts.isEmpty
          ? const Center(
              child: Text(
                "No emergency alerts available",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: provider.alerts.length,
                itemBuilder: (context, index) {
                  final a = provider.alerts[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade50, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // alert heading
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Emergency Alert",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // image + text
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (a['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  a['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (a['image'] != null) const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a['title'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // date time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatDate(a['created_at']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
