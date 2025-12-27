import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/notice.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MemberNoticeList extends StatefulWidget {
  final int societyId;

  const MemberNoticeList({super.key, required this.societyId});

  @override
  State<MemberNoticeList> createState() => _MemberNoticeListState();
}

class _MemberNoticeListState extends State<MemberNoticeList> {
  @override
  void initState() {
    super.initState();
    Provider.of<NoticeProvider>(
      context,
      listen: false,
    ).getNotices(widget.societyId);
  }

  String formatDate(String date) {
    final d = DateTime.parse(date);
    return DateFormat('dd MMM, yyyy • hh:mm a').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoticeProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: "Notices"),
      backgroundColor: Colors.grey.shade100,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notices.isEmpty
          ? const Center(
              child: Text(
                "No notices available",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: provider.notices.length,
                itemBuilder: (context, index) {
                  final n = provider.notices[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notice heading
                        Row(
                          children: [
                            Icon(Icons.campaign, color: Colors.blue, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              "Notice",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Image + Notice text in one row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (n['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  n['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (n['image'] != null) const SizedBox(width: 12),

                            // Notice text
                            Expanded(
                              child: Text(
                                n['notice'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Date and time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatDate(n['created_at']),
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
