import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/modal/service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceProviders extends ChangeNotifier {
  List<ServiceProviderModal> servicesList = [];
  bool isLoading = false;
  final supabase = Supabase.instance.client;

  // ADD service provider
  Future<bool> addServices(ServiceProviderModal service) async {
    try {
      await supabase.from('service_provider').insert(service.toMap());
      return true;
    } catch (e) {
      print("Error adding provider: $e");
      return false;
    }
  }

  //update
  Future<bool> updateProvider(
    int id,
    Map<String, dynamic> updatedData,
    int societyId,
  ) async {
    try {
      await supabase.from('service_provider').update(updatedData).eq('id', id);
      fetchServices(societyId);
      return true;
    } catch (e) {
      print("Update Error: $e");
      return false;
    }
  }

  // FETCH all providers of society
  Future<void> fetchServices(int societyId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('service_provider')
          .select()
          .eq('society_id', societyId)
          .order('created_at', ascending: false);

      servicesList = response
          .map<ServiceProviderModal>((map) => ServiceProviderModal.fromMap(map))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching providers: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // FETCH providers by category
  Future<void> fetchByCategory(int societyId, String category) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('service_provider')
          .select()
          .eq('society_id', societyId)
          .eq('category', category);

      servicesList = response
          .map<ServiceProviderModal>((map) => ServiceProviderModal.fromMap(map))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching by category: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // DELETE provider
  Future<bool> deleteProvider(int id) async {
    try {
      await supabase.from('service_provider').delete().eq('id', id);
      return true;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }
}
