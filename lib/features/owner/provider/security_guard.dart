import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/modal/security_guard.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityGuardProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<SecurityGuardModal> guards = [];

  bool isLoading = false;

  // Fetch all guards
  Future<void> fetchGuards(int societyId) async {
    try {
      final response = await supabase
          .from('security_guard')
          .select('*, societies:society_id(society_name)')
          .eq('society_id', societyId)
          .order('id', ascending: false);

      guards = response
          .map<SecurityGuardModal>((map) => SecurityGuardModal.fromMap(map))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Fetch guards error: $e");
      rethrow;
    }
  }

  Future<bool> addGuard(SecurityGuardModal guard) async {
    try {
      debugPrint("Adding guard with data: ${guard.toMap()}");

      final response = await supabase
          .from('security_guard')
          .insert(guard.toMap())
          .select()
          .single();
      debugPrint("Insert response: $response");

      if (response.isNotEmpty) {
        guards.insert(0, SecurityGuardModal.fromMap(response));
        notifyListeners();
        return true;
      }
      return false;
    } on PostgrestException catch (e) {
      debugPrint("Postgrest error adding guard: ${e.message}");
      debugPrint("Details: ${e.details}");
      debugPrint("Hint: ${e.hint}");
      return false;
    } catch (e) {
      debugPrint("Add guard error: $e");
      return false;
    }
  }

  // Update guard
  Future<bool> updateGuard(SecurityGuardModal guard) async {
    try {
      final updateData = {
        'name': guard.name,
        'phone': guard.phone,
        'address': guard.address,
        'dob': guard.dob,
        'id_proof': guard.idProof,
        'gender': guard.gender,
        'profile_image': guard.profileImage,
      };

      final res = await supabase
          .from('security_guard')
          .update(updateData)
          .eq('id', guard.id)
          .select()
          .single();

      final index = guards.indexWhere((g) => g.id == guard.id);
      if (index != -1) {
        guards[index] = SecurityGuardModal.fromMap(res);
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint("Update guard error: $e");
      return false;
    }
  }

  // Delete guard
  Future<bool> deleteGuard(int guardId) async {
    try {
      await supabase.from('security_guard').delete().eq('id', guardId);
      guards.removeWhere((g) => g.id == guardId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Delete guard error: $e");
      return false;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileExt = imageFile.path.split(".").last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final bytes = await imageFile.readAsBytes();

      // Upload to the bucket
      await supabase.storage
          .from('security_guard')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/*'),
          );

      // Get public URL
      final publicUrl = supabase.storage
          .from('security_guard')
          .getPublicUrl(fileName);

      debugPrint("Image uploaded successfully: $publicUrl");
      return publicUrl;
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }
}
