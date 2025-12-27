import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/help_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HelpProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<HelpModal> _helpList = [];
  List<HelpModal> get helpList => _helpList;

  /// Add New Help Request
  Future<void> addHelp(HelpModal help) async {
    await supabase.from('help').insert(help.toJson());
    await fetchHelpsBySociety(help.societyId);
  }

  /// Fetch All Help Requests for Society
  Future<void> fetchHelpsBySociety(int societyId) async {
    final res = await supabase
        .from('help')
        .select('''
      *,
      members:member_id (
        member_name,
        member_phone,
        flat_no
      )
    ''')
        .eq('society_id', societyId)
        .order('id', ascending: false);

    _helpList = res.map((e) => HelpModal.fromJson(e)).toList();
    notifyListeners();
  }

  /// Delete Help
  Future<void> deleteHelp(int helpId) async {
    try {
      await supabase.from('help').delete().eq('id', helpId);

      _helpList.removeWhere((help) => help.id == helpId);
      notifyListeners();
    } catch (e) {
      print('Error deleting help: $e');
      rethrow;
    }
  }
}
