import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/complaints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintsProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<ComplaintsModal> complaints = [];
  bool isLoading = false;

  Future<void> fetchcomplaintsRequests(int societyId) async {
    try {
      final data = await supabase
          .from('complaints')
          .select('''
      *,
       members!complaints_member_id_fkey (
        member_name,
        profile_image,
        member_phone,
        flat_no
      )
    ''')
          .eq('society_id', societyId)
          .order('created_at', ascending: false);

      complaints = data.map((e) => ComplaintsModal.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching complaints: $e');
      complaints = [];
      notifyListeners();
      rethrow;
    }
  }

  // FETCH COMPLAINTS
  Future<void> fetchComplaints(int memberId) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await supabase
          .from('complaints')
          .select()
          .eq('member_id', memberId)
          .order('created_at', ascending: false);

      complaints = data.map((e) => ComplaintsModal.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching complaints: $e');
      complaints = [];
      rethrow;
    }

    isLoading = false;
    notifyListeners();
  }

  // UPLOAD IMAGE TO STORAGE
  Future<String?> uploadComplaintImage(File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName =
          'complaints/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await supabase.storage.from('complaints').upload(fileName, file);

      final url = supabase.storage.from('complaints').getPublicUrl(fileName);

      return url;
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  // ADD COMPLAINT
  Future<void> addComplaint({
    required int memberId,
    required int societyId,
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    try {
      final response = await supabase.from('complaints').insert({
        'member_id': memberId,
        'society_id': societyId,
        'title': title,
        'description': description,
        'image': imageUrl,
      }).select();

      if (response.isNotEmpty) {
        complaints.insert(0, ComplaintsModal.fromMap(response[0]));
        notifyListeners();
      }
    } catch (e) {
      print("Error adding complaint: $e");
      rethrow;
    }
  }

  // DELETE COMPLAINT
  Future<void> deleteComplaint(int complaintId) async {
    try {
      await supabase.from('complaints').delete().eq('id', complaintId);

      complaints.removeWhere((c) => c.id == complaintId);
      notifyListeners();
    } catch (e) {
      print('Error deleting complaint: $e');
      rethrow;
    }
  }
}
