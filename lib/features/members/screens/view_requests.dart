import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/guest_modal.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/guest.dart';

class GuestRequestListScreen extends StatefulWidget {
  final int memberId;

  const GuestRequestListScreen({super.key, required this.memberId});

  @override
  State<GuestRequestListScreen> createState() => _GuestRequestListScreenState();
}

class _GuestRequestListScreenState extends State<GuestRequestListScreen> {
  String selectedStatusFilter = 'all';
  String selectedTypeFilter = 'all';

  final statusOptions = ['all', 'pending', 'approved', 'rejected'];
  final typeOptions = ['all', 'guest', 'delivery_boy', 'family_member'];

  @override
  void initState() {
    super.initState();
    Provider.of<RequestProvider>(
      context,
      listen: false,
    ).fetchRequestsForMembers(widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RequestProvider>(context);

    // Apply combined filters
    final filteredRequests = provider.requests.where((r) {
      final statusMatch =
          selectedStatusFilter == 'all' ||
          r.status.toLowerCase() == selectedStatusFilter;
      final typeMatch =
          selectedTypeFilter == 'all' || r.request_type == selectedTypeFilter;
      return statusMatch && typeMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: 'Requests', ontap: () => _showFilterDialog()),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchRequests(widget.memberId),
        child: filteredRequests.isEmpty
            ? const Center(
                child: Text(
                  "No Requests Found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final req = filteredRequests[index];
                  return _buildRequestCard(req, provider);
                },
              ),
      ),
    );
  }

  Widget _buildRequestCard(GuestRequest req, RequestProvider provider) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: req.guestImage != null && req.guestImage!.isNotEmpty
                  ? Image.network(
                      req.guestImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 35),
                    ),
            ),
            const SizedBox(width: 12),
            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.guestName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("📞 ${req.guestPhone}"),
                  Text("📍 ${req.guestAddress ?? '--'}"),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(req.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          req.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatRequestType(req.type),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // QR BUTTON
            IconButton(
              icon: const Icon(Icons.qr_code_2, color: Colors.blue),
              onPressed: () {
                if (req.qrCode != null && req.qrCode!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GuestQRCodeScreen(
                        qrData: req.qrCode!,
                        guestName: req.guestName,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatRequestType(String type) {
    switch (type.toLowerCase()) {
      case 'guest':
        return 'Guest';
      case 'delivery_boy':
        return 'Delivery Boy';
      case 'family_member':
        return 'Family Member';
      default:
        return type;
    }
  }

  void _showFilterDialog() {
    String tempStatus = selectedStatusFilter;
    String tempType = selectedTypeFilter;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Filter Requests"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Status"),
                ...statusOptions.map(
                  (status) => RadioListTile<String>(
                    title: Text(status[0].toUpperCase() + status.substring(1)),
                    value: status,
                    groupValue: tempStatus,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempStatus = val!;
                      });
                    },
                  ),
                ),
                const Divider(),
                const Text("Request Type"),
                ...typeOptions.map(
                  (type) => RadioListTile<String>(
                    title: Text(_formatRequestType(type)),
                    value: type,
                    groupValue: tempType,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempType = val!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedStatusFilter = tempStatus;
                  selectedTypeFilter = tempType;
                });
                Navigator.pop(context);
              },
              child: const Text("Apply"),
            ),
          ],
        ),
      ),
    );
  }
}

class GuestQRCodeScreen extends StatelessWidget {
  final String qrData;
  final String guestName;

  const GuestQRCodeScreen({
    super.key,
    required this.qrData,
    required this.guestName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: reuseAppBar(title: "QR Code for $guestName"),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(data: qrData, size: 250, version: QrVersions.auto),
              const SizedBox(height: 20),
              const Text(
                "Share this QR with your guest.\nSecurity guard will scan it.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
