import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyAlertsProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> get alerts => _alerts;

  bool isLoading = false;

  // add method
  Future<void> addAlert({
    required int societyId,
    required String title,
    required String description,
    File? imageFile,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadAlertImage(imageFile);
      }

      await supabase.from('emergency_alert').insert({
        'society_id': societyId,
        'title': title,
        'description': description,
        'image': imageUrl,
      });

      await getAlerts(societyId);
    } catch (e) {
      debugPrint("Error adding alert: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // get method
  Future<void> getAlerts(int societyId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('emergency_alert')
          .select('*')
          .eq('society_id', societyId)
          .order('created_at', ascending: false);

      _alerts = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching alerts: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // remove method
  Future<void> deleteAlert(int alertId, int societyId) async {
    try {
      await supabase.from('emergency_alert').delete().eq('id', alertId);
      await getAlerts(societyId);
    } catch (e) {
      debugPrint("Error deleting alert: $e");
    }
  }

  // update method
  Future<void> updateAlert({
    required int alertId,
    required String title,
    required String description,
    required int societyId,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadAlertImage(imageFile);
      }

      final updateData = {'title': title, 'description': description};

      if (imageUrl != null) updateData['image'] = imageUrl;

      await supabase
          .from('emergency_alert')
          .update(updateData)
          .eq('id', alertId);

      await getAlerts(societyId);
    } catch (e) {
      debugPrint("Error updating alert: $e");
    }
  }

  // upload image method
  Future<String?> uploadAlertImage(File imageFile) async {
    try {
      final ext = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final bytes = await imageFile.readAsBytes();

      await supabase.storage
          .from('alerts')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/*'),
          );

      return supabase.storage.from('alerts').getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Error uploading alert image: $e");
      return null;
    }
  }
}
