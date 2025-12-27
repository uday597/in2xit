import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/screens/complaints.dart';
import 'package:my_gate_clone/features/members/screens/emergency_alerts.dart';
import 'package:my_gate_clone/features/members/screens/events.dart';
import 'package:my_gate_clone/features/members/screens/guest_request.dart';
import 'package:my_gate_clone/features/members/screens/help_requestscreen.dart';
import 'package:my_gate_clone/features/members/screens/new_visitors.dart';
import 'package:my_gate_clone/features/members/screens/notice.dart';
import 'package:my_gate_clone/features/members/screens/notifications.dart';
import 'package:my_gate_clone/features/members/screens/payment.dart';
import 'package:my_gate_clone/features/members/screens/service_providers.dart';
import 'package:my_gate_clone/features/members/screens/view_requests.dart';
import 'package:my_gate_clone/features/owner/modal/members_modal.dart';
import 'package:my_gate_clone/utilis/appbar.dart';

class MemberHomepage extends StatelessWidget {
  final MembersModal member;

  const MemberHomepage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: reuseAppBar(
        title: 'Members Dashboard',
        showBack: false,
        centerTittle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberNotificationsScreen(),
                ),
              );
            },
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(context),
            const SizedBox(height: 24),

            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 4 : 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: isTablet ? 1.1 : 0.9,
              ),
              children: [
                _actionTile(Icons.support_agent, "Help", Colors.indigo, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HelpRequestListScreen(
                        currentMemberFlat: member.memberFlatNo,
                        currentMemberName: member.memberName,
                        currentMemberPhone: member.memberPhone,
                        societyId: member.societyId,
                        memberId: member.id,
                      ),
                    ),
                  );
                }),
                _actionTile(
                  Icons.add_circle_outline,
                  "Request",
                  Colors.green,
                  () => showRequestOptions(context),
                ),
                _actionTile(Icons.receipt_long, "Requests", Colors.orange, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GuestRequestListScreen(memberId: member.id),
                    ),
                  );
                }),
                _actionTile(
                  Icons.miscellaneous_services,
                  "Services",
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberServiceProvidersScreen(
                          societyId: member.societyId,
                        ),
                      ),
                    );
                  },
                ),
                _actionTile(Icons.campaign, "Notices", Colors.purple, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MemberNoticeList(societyId: member.societyId),
                    ),
                  );
                }),
                _actionTile(Icons.meeting_room, "Visitors", Colors.brown, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemberVisitorsScreen(memberId: member.id),
                    ),
                  );
                }),
                _actionTile(Icons.warning_amber, "Emergency", Colors.red, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemberEmergencyAlertsList(
                        societyId: member.societyId,
                      ),
                    ),
                  );
                }),
                _actionTile(Icons.payments, "Payments", Colors.teal, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemberPaymentScreen(
                        memberId: member.id,
                        societyId: member.societyId,
                      ),
                    ),
                  );
                }),
                _actionTile(
                  Icons.report_problem,
                  "Complaints",
                  Colors.cyan.shade700,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddComplaintScreen(
                          memberId: member.id,
                          societyId: member.societyId,
                        ),
                      ),
                    );
                  },
                ),
                _actionTile(Icons.logout, 'Logout', Colors.blueGrey, () {
                  Navigator.pushReplacementNamed(context, '/rolescreen');
                }),
              ],
            ),

            const SizedBox(height: 30),
            EventsSection(member: member),
          ],
        ),
      ),
    );
  }

  //  PROFILE CARD
  Widget _profileCard(BuildContext context) {
    return GestureDetector(
      onTap: () => showMemberInfo(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage:
                  member.memberImage != null && member.memberImage!.isNotEmpty
                  ? NetworkImage(member.memberImage!)
                  : const AssetImage("assets/images/user.png") as ImageProvider,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.memberName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Flat ${member.memberFlatNo}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Active Member",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ACTION TILE
  Widget _actionTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- MEMBER INFO ----------------
  void showMemberInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage:
                  member.memberImage != null && member.memberImage!.isNotEmpty
                  ? NetworkImage(member.memberImage!)
                  : const AssetImage("assets/images/user.png") as ImageProvider,
            ),
            const SizedBox(height: 12),
            Text(
              member.memberName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _infoRow("Email", member.memberEmail),
            _infoRow("Phone", member.memberPhone),
            _infoRow("Flat", member.memberFlatNo),
            _infoRow("Tower", member.tower),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  //  REQUEST OPTIONS
  void showRequestOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Create Request",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _requestTile(context, "Guest", Icons.people),
            _requestTile(context, "Relative", Icons.person),
            _requestTile(context, "Student", Icons.person_4),

            _requestTile(context, "Delivery Boy", Icons.delivery_dining),
            _requestTile(context, "Family Member", Icons.family_restroom),
          ],
        ),
      ),
    );
  }

  Widget _requestTile(BuildContext context, String type, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(type),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GuestRequestScreen(member: member, defaultRequestType: type),
          ),
        );
      },
    );
  }
}
