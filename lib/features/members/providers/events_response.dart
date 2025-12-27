// features/members/providers/events_response.dart
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/event_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventResponseProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  Map<int, List<EventResponseModal>> eventResponses = {};
  Map<int, bool> loadingStates = {};

  Future<void> fetchResponses(int eventId) async {
    loadingStates[eventId] = true;
    notifyListeners();

    try {
      final responsesData = await supabase
          .from('event_responses')
          .select('''
      *,
      members:member_id (
        member_name,
        profile_image
      )
    ''')
          .eq('event_id', eventId)
          .order('created_at', ascending: true);

      eventResponses[eventId] = responsesData.map<EventResponseModal>((e) {
        return EventResponseModal.fromMap(e);
      }).toList();
    } catch (e) {
      print("Error fetching responses: $e");
      eventResponses[eventId] = [];
    }

    loadingStates[eventId] = false;
    notifyListeners();
  }

  Future<void> addResponse({
    required int eventId,
    required int memberId,
    required String type,
    String? comment,
  }) async {
    try {
      final response = await supabase
          .from('event_responses')
          .insert({
            'event_id': eventId,
            'member_id': memberId,
            'type': type,
            'comment': comment,
          })
          .select()
          .single();

      final memberData = await supabase
          .from('members')
          .select('member_name, profile_image')
          .eq('id', memberId)
          .single();

      final newResponse = EventResponseModal(
        id: response['id'],
        eventId: response['event_id'],
        memberId: response['member_id'],
        type: response['type'],
        comment: response['comment'],
        createdAt: DateTime.parse(response['created_at']),
        memberName: memberData['member_name'],
        memberImage: memberData['profile_image'],
      );

      if (!eventResponses.containsKey(eventId)) {
        eventResponses[eventId] = [];
      }
      eventResponses[eventId]!.insert(0, newResponse);
      notifyListeners();
    } catch (e) {
      print("Error adding response: $e");
      rethrow;
    }
  }

  Future<void> deleteResponse(int responseId, int eventId) async {
    try {
      await supabase.from('event_responses').delete().eq('id', responseId);
      eventResponses[eventId]?.removeWhere((r) => r.id == responseId);
      notifyListeners();
    } catch (e) {
      print("Error deleting response: $e");
      rethrow;
    }
  }

  bool isLoading(int eventId) => loadingStates[eventId] ?? false;
  List<EventResponseModal> getResponses(int eventId) =>
      eventResponses[eventId] ?? [];
}
