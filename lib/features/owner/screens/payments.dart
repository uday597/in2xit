import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/providers/payment.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class AdminSidePayment extends StatefulWidget {
  final int societyId;
  const AdminSidePayment({super.key, required this.societyId});

  @override
  State<AdminSidePayment> createState() => _AdminSidePaymentState();
}

class _AdminSidePaymentState extends State<AdminSidePayment> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().getPaymentsAdminSide(widget.societyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: 'All Payments'),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.payments.length,
              itemBuilder: (context, index) {
                final payment = provider.payments[index];

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// MEMBER INFO
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment.memberName ?? 'Unknown Member',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Flat: ${payment.flatNo ?? '-'} • ${payment.memberPhone ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _statusBadge(payment.status),
                          ],
                        ),

                        const Divider(height: 24),

                        /// PAYMENT DETAILS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹ ${payment.amount}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              payment.reason,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),

                        /// PAYMENT IMAGE
                        if (payment.paymentImage != null) ...[
                          const SizedBox(height: 12),
                          paymentImagePreview(
                            context: context,
                            imageUrl: payment.paymentImage!,
                          ),
                        ],

                        /// ACTION BUTTONS
                        if (payment.status == 'pending') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () {
                                    provider.updatePaymentStatus(
                                      paymentId: payment.id,
                                      status: 'approved',
                                      societyId: widget.societyId,
                                    );
                                  },
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    provider.updatePaymentStatus(
                                      paymentId: payment.id,
                                      status: 'rejected',
                                      societyId: widget.societyId,
                                    );
                                  },
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// STATUS BADGE
  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Widget paymentImagePreview({
  required BuildContext context,
  required String imageUrl,
}) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(imageUrl),
            ),
          );
        },
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    ),
  );
}
