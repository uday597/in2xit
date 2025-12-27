// features/members/providers/events.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/events.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<EventsModal> events = [];
  bool isLoading = false;

  Future<void> fetchEvents(int societyId, {int? currentMemberId}) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await supabase
          .from('events')
          .select('''* ,members:member_id(member_name,profile_image)''')
          .eq('society_id', societyId)
          .order('created_at', ascending: false);

      List<dynamic> filteredData = [];

      for (var e in data) {
        final event = EventsModal.fromMap(e);

        if (event.visibility == 'public' ||
            event.memberId == currentMemberId ||
            (event.visibility == 'selective' &&
                event.selectedMemberIds.contains(currentMemberId))) {
          filteredData.add(e);
        }
      }

      events = filteredData.map((e) => EventsModal.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching events: $e");
      rethrow;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<String?> uploadEventImage(File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = 'events/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await supabase.storage.from('events').upload(fileName, file);
      final url = supabase.storage.from('events').getPublicUrl(fileName);
      return url;
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  Future<void> addEvent({
    required String title,
    required String description,
    String? imageUrl,
    required int societyId,
    required int memberId,
    String visibility = 'public',
    List<int>? visibleTo,
  }) async {
    try {
      final visibleToCsv = visibleTo?.join(',');

      final response = await supabase.from('events').insert({
        'title': title,
        'description': description,
        'image': imageUrl,
        'society_id': societyId,
        'member_id': memberId,
        'visibility': visibility,
        'visible_to': visibleToCsv,
      }).select();

      if (response.isNotEmpty) {
        events.insert(0, EventsModal.fromMap(response[0]));
        notifyListeners();
      }
    } catch (e) {
      print("Error adding event: $e");
      rethrow;
    }
  }

  Future<void> updateEvent(EventsModal event) async {
    try {
      final visibleToCsv = event.selectedMemberIds.join(',');

      final response = await supabase
          .from('events')
          .update({
            'title': event.title,
            'description': event.description,
            'image': event.image,
            'visibility': event.visibility,
            'visible_to': visibleToCsv,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.id)
          .select();

      if (response.isNotEmpty) {
        final index = events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          events[index] = event;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error updating event: $e");
      rethrow;
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await supabase.from('events').delete().eq('id', id);
      events.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting event: $e");
      rethrow;
    }
  }
}
