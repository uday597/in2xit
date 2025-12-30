import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_gate_clone/features/admin/provider/society_provider.dart';
import 'package:my_gate_clone/features/members/providers/complaints.dart';
import 'package:my_gate_clone/features/members/providers/events.dart';
import 'package:my_gate_clone/features/members/providers/events_response.dart';
import 'package:my_gate_clone/features/members/providers/guest.dart';
import 'package:my_gate_clone/features/members/providers/help_request.dart';
import 'package:my_gate_clone/features/members/providers/help_response.dart';
import 'package:my_gate_clone/features/members/providers/login_provider.dart';
import 'package:my_gate_clone/features/members/providers/payment.dart';
import 'package:my_gate_clone/features/owner/provider/emergency_alerts.dart';
import 'package:my_gate_clone/features/owner/provider/login_provider.dart';
import 'package:my_gate_clone/features/owner/provider/members_provider.dart';
import 'package:my_gate_clone/features/owner/provider/notice.dart';
import 'package:my_gate_clone/features/owner/provider/security_guard.dart';
import 'package:my_gate_clone/features/owner/provider/service_provider.dart';
import 'package:my_gate_clone/features/owner/provider/student.dart';
import 'package:my_gate_clone/features/security_guard/providers/login.dart';
import 'package:my_gate_clone/features/security_guard/providers/visitor.dart';
import 'package:my_gate_clone/firebase_options.dart';
import 'package:my_gate_clone/notifications_service.dart';
import 'package:my_gate_clone/routing/routing.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger().f("Logger notifications backend setup");
}

const supabaseUrl = 'https://ilkbggbpapwcqmnwsmxd.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlsa2JnZ2JwYXB3Y3FtbndzbXhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4MDEyMjcsImV4cCI6MjA4MjM3NzIyN30.n8MHW0guudKlfaAwWfOREBDAvMRbR9H2rmd3fjiEnik';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().init();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyAlertsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => VisitorProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => EventResponseProvider()),
        ChangeNotifierProvider(create: (_) => HelpProvider()),
        ChangeNotifierProvider(create: (_) => HelpResponseProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => SecurityGuardLoginProvider()),
        ChangeNotifierProvider(create: (_) => SecurityGuardProvider()),
        ChangeNotifierProvider(create: (_) => MembersLoginProvider()),
        ChangeNotifierProvider(create: (_) => MembersProvider()),
        ChangeNotifierProvider(create: (_) => SocietyProvider()),
        ChangeNotifierProvider(create: (_) => OwnerLoginProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProviders()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRouting.routes,
      title: 'My gate',
      theme: ThemeData(),
    );
  }
}
