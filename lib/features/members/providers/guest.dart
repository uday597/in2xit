import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/guest_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<GuestRequest> _requests = [];
  List<GuestRequest> get requests => _requests;

  // Upload to public bucket
  Future<String?> uploadGuestImage(File image) async {
    try {
      final ext = image.path.split('.').last;
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";
      final fileBytes = await image.readAsBytes();

      await supabase.storage
          .from("guest")
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(contentType: 'image/*'),
          );

      return supabase.storage.from("guest").getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Image Upload Error: $e");
      return null;
    }
  }

  // FETCH REQUEST USING QR CODE
  Future<GuestRequest?> fetchRequestByQR(String qrString) async {
    try {
      if (!qrString.startsWith("guest|req:")) {
        debugPrint("Invalid QR format");
        return null;
      }

      final parts = qrString.split("|");
      final reqPart = parts[1]; // req:ID
      final requestId = int.parse(reqPart.replaceAll("req:", ""));

      final data = await supabase
          .from("guest_requests")
          .select('*, members:member_id(member_name)')
          .eq("id", requestId)
          .maybeSingle();

      if (data == null) return null;

      return GuestRequest.fromMap(data);
    } catch (e) {
      debugPrint("QR Fetch Error: $e");
      return null;
    }
  }

  // ADD REQUEST + generate QR
  Future<bool> addGuestRequest({
    required int societyId,
    required int memberId,
    required String guestName,
    required String guestAddress,
    required String guestPhone,
    File? guestImageFile,
    required String requestType,
  }) async {
    try {
      String? imageUrl;

      if (guestImageFile != null) {
        imageUrl = await uploadGuestImage(guestImageFile);
      }

      final inserted = await supabase
          .from("guest_requests")
          .insert({
            "society_id": societyId,
            "member_id": memberId,
            "guest_name": guestName,
            "guest_address": guestAddress,
            "guest_phone": guestPhone,
            "guest_image": imageUrl ?? "",
            "status": "pending",
            'request_type': requestType,
            "created_at": DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final requestId = inserted['id'];

      // QR string
      final qrString =
          "guest|req:$requestId|member:$memberId|society:$societyId";

      await supabase
          .from("guest_requests")
          .update({"qr_code": qrString})
          .eq("id", requestId);

      fetchRequests(societyId);

      return true;
    } catch (e) {
      debugPrint("Add Request Error: $e");
      return false;
    }
  }

  Future<void> updateStatus({required int id, required String status}) async {
    try {
      final Map<String, dynamic> updateData = {
        "status": status,
        "guard_action_at": DateTime.now().toIso8601String(),
      };

      if (status == "in") {
        updateData["in_time"] = DateTime.now().toIso8601String();
      }

      if (status == "out") {
        updateData["out_time"] = DateTime.now().toIso8601String();
      }

      await supabase.from("guest_requests").update(updateData).eq("id", id);

      fetchRequests(_requests.first.societyId);
    } catch (e) {
      debugPrint("Update Status Error: $e");
    }
  }

  // UPDATE
  Future<bool> updateRequest({
    required int id,
    required int societyId,
    String? guestName,
    String? guestAddress,
    String? guestPhone,
    File? newImageFile,
    String? status,
  }) async {
    try {
      String? imageUrl;

      if (newImageFile != null) {
        imageUrl = await uploadGuestImage(newImageFile);
      }

      final updateData = {
        if (guestName != null) "guest_name": guestName,
        if (guestAddress != null) "guest_address": guestAddress,
        if (guestPhone != null) "guest_phone": guestPhone,
        if (imageUrl != null) "guest_image": imageUrl,
        if (status != null) "status": status,
      };

      await supabase.from("guest_requests").update(updateData).eq("id", id);

      fetchRequests(societyId);
      return true;
    } catch (e) {
      debugPrint("Update Request Error: $e");
      return false;
    }
  }

  // DELETE
  Future<bool> deleteRequest(int id, int societyId) async {
    try {
      await supabase.from("guest_requests").delete().eq("id", id);
      fetchRequests(societyId);
      return true;
    } catch (e) {
      debugPrint("Delete Request Error: $e");
      return false;
    }
  }

  // FETCH
  Future<void> fetchRequests(int memberId) async {
    try {
      final response = await supabase
          .from("guest_requests")
          .select('*, members:member_id(member_name,flat_no)')
          .eq("society_id", memberId)
          .order("id", ascending: false);

      _requests = response.map((e) => GuestRequest.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Requests Error: $e");
    }
  }

  Future<void> fetchRequestsForMebers(int memberId) async {
    try {
      final response = await supabase
          .from("guest_requests")
          .select('*, members:member_id(member_name,flat_no)')
          .eq("member_is", memberId)
          .order("id", ascending: false);

      _requests = response.map((e) => GuestRequest.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Requests Error: $e");
    }
  }

  Future<void> fetchRequestsForMembers(int memberId) async {
    try {
      final response = await supabase
          .from("guest_requests")
          .select('*, members:member_id(member_name,flat_no)')
          .eq("member_id", memberId)
          .order("id", ascending: false);

      _requests = response.map((e) => GuestRequest.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Requests Error: $e");
    }
  }
}
