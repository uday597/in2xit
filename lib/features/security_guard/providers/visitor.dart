import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/security_guard/modal/visitors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisitorProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<VisitorModal> _visitorList = [];
  List<VisitorModal> get visitorList => _visitorList;

  //fetch
  Future<void> fetchVisitors(int societyId) async {
    final data = await supabase
        .from('visitor')
        .select()
        .eq('society_id', societyId);
    _visitorList = data
        .map((e) => VisitorModal.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  // Update only visitor status
  Future<bool> updateVisitorStatus(int id, String status) async {
    try {
      final now = DateTime.now();

      final updateData = {
        "status": status,
        if (status == "in") "in_time": now.toIso8601String(),
        if (status == "out") "out_time": now.toIso8601String(),
      };

      await supabase.from('visitor').update(updateData).eq('id', id);

      final index = _visitorList.indexWhere((v) => v.id == id);
      if (index != -1) {
        _visitorList[index] = _visitorList[index].copyWith(
          status: status,
          inTime: status == "in" ? now : _visitorList[index].inTime,
          outTime: status == "out" ? now : _visitorList[index].outTime,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint("Status Update Error: $e");
      return false;
    }
  }

  // Fetch visitor requests for a specific member
  Future<void> fetchVisitorsForMember(int memberId) async {
    try {
      final data = await supabase
          .from('visitor')
          .select()
          .eq('member_id', memberId)
          .order('id', ascending: false);

      _visitorList = data
          .map((e) => VisitorModal.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Member Visitors Error: $e");
    }
  }

  //add
  Future<bool> addVisitor(VisitorModal visitor, String? imagePath) async {
    try {
      String? imageUrl;

      if (imagePath != null) {
        final fileName = "visitor_${DateTime.now().millisecondsSinceEpoch}.jpg";
        imageUrl = await uploadVisitorImage(imagePath, fileName);
      }

      final data = await supabase
          .from('visitor')
          .insert({
            ...visitor.toMap(),
            "image": imageUrl, // NEW
          })
          .select()
          .single();

      _visitorList.add(VisitorModal.fromMap(data));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Add Visitor Error: $e");
      return false;
    }
  }

  //update
  Future<bool> updateVisitor(VisitorModal visitor) async {
    try {
      await supabase
          .from('visitor')
          .update(visitor.toMap())
          .eq('id', visitor.id);

      final index = _visitorList.indexWhere((v) => v.id == visitor.id);

      if (index != -1) {
        _visitorList[index] = visitor;
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    }
  }

  //delte
  Future<bool> deleteVisitor(int id) async {
    try {
      await supabase.from('visitor').delete().eq('id', id);

      _visitorList.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      return false;
    }
  }

  Future<String?> uploadVisitorImage(String path, String fileName) async {
    try {
      final file = File(path);

      await supabase.storage
          .from('visitor')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final url = supabase.storage.from('visitor').getPublicUrl(fileName);

      return url;
    } catch (e) {
      debugPrint("Image Upload Error: $e");
      return null;
    }
  }
}
