import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_clone/features/members/modal/payment.dart';
import 'package:my_gate_clone/features/members/providers/payment.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class MemberPaymentScreen extends StatefulWidget {
  final int societyId;
  final int memberId;

  const MemberPaymentScreen({
    super.key,
    required this.societyId,
    required this.memberId,
  });

  @override
  State<MemberPaymentScreen> createState() => _MemberPaymentScreenState();
}

class _MemberPaymentScreenState extends State<MemberPaymentScreen> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  File? _selectedImage;
  PaymentModal? _editingPayment;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().getPayments(widget.memberId);
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _startEdit(PaymentModal payment) {
    setState(() {
      _editingPayment = payment;
      _amountController.text = payment.amount.toString();
      _reasonController.text = payment.reason;
    });
  }

  void _clearForm() {
    _amountController.clear();
    _reasonController.clear();
    _selectedImage = null;
    _editingPayment = null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: reuseAppBar(title: 'Payments'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PAYMENT FORM
            Text(
              _editingPayment != null ? 'Update Payment' : 'Add Payment',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Upload Screenshot'),
                ),
                const SizedBox(width: 12),
                _selectedImage != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Text('No image'),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final amount = double.tryParse(
                          _amountController.text.trim(),
                        );
                        final reason = _reasonController.text.trim();

                        if (amount == null || reason.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter valid details'),
                            ),
                          );
                          return;
                        }

                        if (_editingPayment != null) {
                          await provider.updatePayment(
                            paymentId: _editingPayment!.id,
                            amount: amount,
                            reason: reason,
                            memberId: widget.memberId,
                            imageFile: _selectedImage,
                          );
                        } else {
                          await provider.addPayment(
                            societyId: widget.societyId,
                            memberId: widget.memberId,
                            amount: amount,
                            reason: reason,
                            imageFile: _selectedImage,
                          );
                        }

                        _clearForm();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _editingPayment != null
                              ? 'Update Payment'
                              : 'Submit Payment',
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 10),

            // ================= PAYMENT LIST =================
            const Text(
              'Your Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            provider.payments.isEmpty
                ? const Center(child: Text('No payments found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.payments.length,
                    itemBuilder: (context, index) {
                      final payment = provider.payments[index];

                      return Card(
                        color: Colors.grey[100],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: payment.paymentImage != null
                              ? Image.network(
                                  payment.paymentImage!,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.payment, size: 40),
                          title: Text('₹${payment.amount} - ${payment.reason}'),
                          subtitle: Text(
                            'Status: ${payment.status}',
                            style: TextStyle(
                              color: payment.status == 'pending'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          trailing: payment.status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _startEdit(payment),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await provider.deletePayment(
                                          payment.id,
                                          widget.memberId,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
