import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_gate_clone/features/admin/modal/society.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerLoginProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool isloading = false;
  CollegeModal? ownerLogged;

  Future<String?> loginOwner({
    required String ownerEmail,
    required String collegePassword,
  }) async {
    try {
      isloading = true;
      notifyListeners();

      final response = await supabase
          .from('college')
          .select()
          .eq('owner_email', ownerEmail)
          .eq('college_password', collegePassword)
          .maybeSingle();

      if (response != null) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          Logger().f("FCM Token is: $fcmToken");
          await supabase
              .from('college')
              .update({'fcm_token': fcmToken})
              .eq('owner_email', ownerEmail);
        }
        notifyListeners();
      } else {
        isloading = false;
        notifyListeners();
        return "Invalid email or password!";
      }

      ownerLogged = CollegeModal.fromMap(response);

      isloading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isloading = false;
      notifyListeners();
      return "Something went wrong: $e";
    }
  }
}
