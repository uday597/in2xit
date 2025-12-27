import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/admin/screens/add_society%20.dart';
import 'package:my_gate_clone/features/members/screens/login.dart';
import 'package:my_gate_clone/features/owner/screens/login.dart';
import 'package:my_gate_clone/features/security_guard/screens/login.dart';
import 'package:my_gate_clone/role_screen.dart';
import 'package:my_gate_clone/splash_screen.dart';

class AppRouting {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/rolescreen': (context) => RoleScreen(),
    '/addsociety': (context) => SocietyScreen(),
    '/ownerlogin': (context) => OwnerLogin(),
    '/memberlogin': (context) => MemberLogin(),
    '/guardlogin': (context) => SecurityGuardLogin(),
  };
}
