import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<PaymentModal> _payments = [];
  List<PaymentModal> get payments => _payments;

  bool isLoading = false;

  // GET PAYMENTS (Member)
  Future<void> getPayments(int memberId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('payments')
          .select('*')
          .eq('member_id', memberId)
          .order('created_at', ascending: false);

      _payments = response
          .map<PaymentModal>((e) => PaymentModal.fromMap(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching payments: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPaymentsAdminSide(int societyId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('payments')
          .select('*,members(member_name,flat_no,member_phone)')
          .eq('society_id', societyId)
          .order('created_at', ascending: false);

      _payments = response
          .map<PaymentModal>((e) => PaymentModal.fromMap(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching payments: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ADD PAYMENT
  Future<void> addPayment({
    required int societyId,
    required int memberId,
    required double amount,
    required String reason,
    File? imageFile,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadPaymentImage(imageFile);
      }

      await supabase.from('payments').insert({
        'society_id': societyId,
        'member_id': memberId,
        'amount': amount,
        'reason': reason,
        'payment_image': imageUrl,
        'status': 'pending',
      });

      await getPayments(memberId);
    } catch (e) {
      debugPrint('Error adding payment: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE PAYMENT (only if pending)
  Future<void> updatePayment({
    required int paymentId,
    required double amount,
    required String reason,
    required int memberId,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadPaymentImage(imageFile);
      }

      final updateData = {
        'amount': amount,
        'reason': reason,
        'status': 'pending',
      };

      if (imageUrl != null) {
        updateData['payment_image'] = imageUrl;
      }

      await supabase.from('payments').update(updateData).eq('id', paymentId);

      await getPayments(memberId);
    } catch (e) {
      debugPrint('Error updating payment: $e');
    }
  }

  //DELETE PAYMENT
  Future<void> deletePayment(int paymentId, int memberId) async {
    try {
      await supabase.from('payments').delete().eq('id', paymentId);
      await getPayments(memberId);
    } catch (e) {
      debugPrint('Error deleting payment: $e');
    }
  }

  // UPLOAD IMAGE
  Future<String?> uploadPaymentImage(File imageFile) async {
    try {
      final ext = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final bytes = await imageFile.readAsBytes();

      await supabase.storage
          .from('payment')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/*'),
          );

      return supabase.storage.from('payment').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> updatePaymentStatus({
    required int paymentId,
    required String status, // approved / rejected
    required int societyId,
  }) async {
    try {
      await supabase
          .from('payments')
          .update({'status': status})
          .eq('id', paymentId);

      await getPaymentsAdminSide(societyId);
    } catch (e) {
      debugPrint('Error updating payment status: $e');
    }
  }
}
