import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/help_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HelpResponseProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<HelpResponseModal> _responseList = [];
  List<HelpResponseModal> get responseList => _responseList;

  void clearResponses() {
    _responseList.clear();
    notifyListeners();
  }

  Future<void> addResponse(HelpResponseModal response) async {
    try {
      final responseData = response.toJson();

      final result = await _supabase
          .from('help_response')
          .insert(responseData)
          .select('''
            *,
            members:member_id(
              member_name,
              member_phone,
              flat_no
            )
          ''');

      if (result.isNotEmpty) {
        final newResponse = HelpResponseModal.fromJson(result[0]);
        _responseList.add(newResponse);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding response: $e');
      rethrow;
    }
  }

  Future<void> fetchResponsesByHelpId(int helpId) async {
    try {
      final responses = await _supabase
          .from('help_response')
          .select('''
        *,
        members:member_id(
          member_name,
          member_phone,
          flat_no
        )
      ''')
          .eq('help_id', helpId)
          .order('created_at', ascending: true);

      _responseList.removeWhere((r) => r.helpId == helpId);

      for (var response in responses) {
        _responseList.add(HelpResponseModal.fromJson(response));
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching responses: $e');
    }
  }

  Future<void> deleteResponse(int responseId) async {
    try {
      await _supabase.from('help_response').delete().eq('id', responseId);

      _responseList.removeWhere((response) => response.id == responseId);
      notifyListeners();
    } catch (e) {
      print('Error deleting response: $e');
      rethrow;
    }
  }
}
