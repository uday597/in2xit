import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/modal/members_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembersProvider extends ChangeNotifier {
  List<MembersModal> members = [];
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  Future<void> fatchMembersList(int societyId) async {
    try {
      isLoading = true;
      final response = await supabase
          .from('members')
          .select()
          .eq('society_id', societyId);
      members = (response as List)
          .map((data) => MembersModal.fromMap(data))
          .toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      const bucketName = 'member';

      await supabase.storage
          .from(bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      return null;
    }
  }

  Future<void> addMembers(MembersModal member) async {
    try {
      await supabase.from('members').insert(member.toMap());

      await fatchMembersList(member.societyId); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMember(MembersModal id, MembersModal member) async {
    try {
      await supabase.from('members').update(member.toMap()).eq('id', member.id);
      await fatchMembersList(member.societyId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSociety(int id) async {
    try {
      await supabase.from('members').delete().eq('id', id);

      members.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
