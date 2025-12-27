import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoticeProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _notices = [];
  List<Map<String, dynamic>> get notices => _notices;

  bool isLoading = false;

  // ADD NEW NOTICE
  Future<void> addNotice({
    required int societyId,
    required String notice,
    File? imageFile,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadNoticeImage(imageFile);
      }

      await supabase.from('notice').insert({
        'society_id': societyId,
        'notice': notice,
        'image': imageUrl,
      });

      await getNotices(societyId); // refresh list
    } catch (e) {
      debugPrint("Error adding notice: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // GET ALL NOTICES
  Future<void> getNotices(int societyId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('notice')
          .select('*')
          .eq('society_id', societyId)
          .order('created_at', ascending: false);

      _notices = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching notices: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // DELETE NOTICE
  Future<void> deleteNotice(int noticeId, int societyId) async {
    try {
      await supabase.from('notice').delete().eq('id', noticeId);
      await getNotices(societyId);
    } catch (e) {
      debugPrint("Error deleting notice: $e");
    }
  }

  // UPDATE NOTICE
  Future<void> updateNotice({
    required int noticeId,
    required String noticeText,
    required int societyId,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadNoticeImage(imageFile);
      }

      final updateData = {'notice': noticeText};
      if (imageUrl != null) updateData['image'] = imageUrl;

      await supabase.from('notice').update(updateData).eq('id', noticeId);

      await getNotices(societyId);
    } catch (e) {
      debugPrint("Error updating notice: $e");
    }
  }

  // UPLOAD IMAGE TO SUPABASE
  Future<String?> uploadNoticeImage(File imageFile) async {
    try {
      final ext = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final bytes = await imageFile.readAsBytes();

      await supabase.storage
          .from('notice')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/*'),
          );

      final url = supabase.storage.from('notice').getPublicUrl(fileName);
      return url;
    } catch (e) {
      debugPrint("Error uploading notice image: $e");
      return null;
    }
  }
}
