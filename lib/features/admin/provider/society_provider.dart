import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/admin/modal/society.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocietyProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<CollegeModal> societies = [];
  bool isLoading = false;
  CollegeModal? crruntSociety;
  // Fetch all societies
  Future<void> fetchSocieties() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase.from('college').select();

      societies = (response as List)
          .map((data) => CollegeModal.fromMap(data))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchCurrentSociety(int societyId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('college')
          .select()
          .eq('id', societyId)
          .maybeSingle();

      if (response != null) {
        crruntSociety = CollegeModal.fromMap(response);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addSociety(CollegeModal society) async {
    try {
      await supabase.from('college').insert(society.toMap());

      await fetchSocieties(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  // Update Society
  Future<void> updateSociety(int id, CollegeModal society) async {
    try {
      await supabase.from('college').update(society.toMap()).eq('id', id);

      await fetchSocieties();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSociety(int id) async {
    try {
      await supabase.from('college').delete().eq('id', id);

      societies.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
