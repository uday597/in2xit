import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_gate_clone/features/owner/modal/members_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembersLoginProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool isLoading = false;
  MembersModal? memberLogged;

  Future<MembersModal?> loginMember({
    required String memberEmail,
    required String memberPassword,
  }) async {
    try {
      final response = await supabase
          .from("members")
          .select()
          .eq("member_email", memberEmail)
          .eq("flat_no", memberPassword)
          .maybeSingle();
      if (response == memberEmail && response == memberPassword) {}
      if (response != null) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          Logger().f("FCM Token is: $fcmToken");
          await supabase
              .from('members')
              .update({'fcm_token': fcmToken})
              .eq('member_email', memberEmail);
        }
        notifyListeners();
        return MembersModal.fromMap(response);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
