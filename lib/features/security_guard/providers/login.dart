import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_gate_clone/features/owner/modal/security_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityGuardLoginProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  SecurityGuardModal? guardLogin;
  Future<String?> loginGuard({required String phone}) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('security_guard')
          .select('''*,college:society_id(college_name)''')
          .eq('phone', phone)
          .maybeSingle();
      if (response != null) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          Logger().f("FCM Token is: $fcmToken");
          await supabase
              .from('security_guard')
              .update({'fcm_token': fcmToken})
              .eq('phone', phone);
        }
        notifyListeners();
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        return "Invalid phone number!";
      }

      guardLogin = SecurityGuardModal.fromMap(response);
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Something went wrong: $e";
    }
  }
}
