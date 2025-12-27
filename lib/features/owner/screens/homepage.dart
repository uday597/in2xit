import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/admin/modal/society.dart';
import 'package:my_gate_clone/features/owner/screens/add_members.dart';
import 'package:my_gate_clone/features/owner/screens/add_securityGuard.dart';
import 'package:my_gate_clone/features/owner/screens/complaints.dart';
import 'package:my_gate_clone/features/owner/screens/emergancy_alert.dart';
import 'package:my_gate_clone/features/owner/screens/guard_list.dart';
import 'package:my_gate_clone/features/owner/screens/members_list.dart';
import 'package:my_gate_clone/features/owner/screens/notice.dart';
import 'package:my_gate_clone/features/owner/screens/payments.dart';
import 'package:my_gate_clone/features/owner/screens/service_provider.dart';
import 'package:my_gate_clone/role_screen.dart';
import 'package:my_gate_clone/utilis/appbar.dart';

class OwnerHomepage extends StatefulWidget {
  final CollegeModal owner;
  const OwnerHomepage({super.key, required this.owner});

  @override
  State<OwnerHomepage> createState() => _OwnerHomepageState();
}

class _OwnerHomepageState extends State<OwnerHomepage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // screen width [web:65]

    // breakpoints
    final bool isTablet = width >= 600; // you can tweak 600 as needed [web:65]

    // grid config
    final int crossAxisCount = isTablet ? 4 : 3;
    final double childAspectRatio = isTablet ? 1.1 : 0.85;
    final EdgeInsets pagePadding = EdgeInsets.symmetric(
      horizontal: isTablet ? 24 : 16,
      vertical: isTablet ? 24 : 16,
    );

    final List<Map<String, dynamic>> features = [
      {
        'title': 'Add Members',
        'icon': Icons.group_add,
        'screen': AddMembers(ownerID: widget.owner.id),
        'color': const Color(0xFF667EEA),
        'navType': navType.push,
      },
      {
        'title': 'Add Students',
        'icon': Icons.badge,
        'screen': AddSecurityGuard(societyId: widget.owner.id),
        'color': const Color(0xFF48BB78),
        'navType': navType.push,
      },
      {
        'title': 'Add Security',
        'icon': Icons.security,
        'screen': AddSecurityGuard(societyId: widget.owner.id),
        'color': const Color(0xFF48BB78),
        'navType': navType.push,
      },
      {
        'title': 'Add Services',
        'icon': Icons.design_services,
        'screen': ProvidersListScreen(societyId: widget.owner.id),
        'color': const Color(0xFFED8936),
        'navType': navType.push,
      },
      {
        'title': 'View Guards',
        'icon': Icons.shield_outlined,
        'screen': GuardsList(societyId: widget.owner.id),
        'color': const Color(0xFFF56565),
        'navType': navType.push,
      },
      {
        'title': 'View Members',
        'icon': Icons.group,
        'screen': MembersListScreen(societyId: widget.owner.id),
        'color': const Color(0xFF4299E1),
        'navType': navType.push,
      },
      {
        'title': 'Notice',
        'icon': Icons.notifications,
        'screen': Notice(socityId: widget.owner.id),
        'color': const Color(0xFF9F7AEA),
        'navType': navType.push,
      },
      {
        'title': 'Complaints',
        'icon': Icons.edit_document,
        'screen': ComplaintsRequests(socityId: widget.owner.id),
        'color': Colors.teal,
        'navType': navType.push,
      },
      {
        'title': 'Emergency Alerts',
        'icon': Icons.add_alert,
        'screen': EmergencyAlertsScreen(socityId: widget.owner.id),
        'color': Colors.red,
        'navType': navType.push,
      },
      {
        'title': 'Payments',
        'icon': Icons.currency_rupee,
        'screen': AdminSidePayment(societyId: widget.owner.id),
        'color': Colors.green,
        'navType': navType.push,
      },
      {
        'title': 'Logout',
        'icon': Icons.logout,
        'screen': RoleScreen(),
        'color': Colors.grey,
        'navType': navType.replace,
      },
    ];

    return Scaffold(
      appBar: reuseAppBar(
        title: "Admin Dashboard",
        showBack: false,
        centerTittle: true,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => showOwnerInfo(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                child: Row(
                  crossAxisAlignment: isTablet
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 40 : 35,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.apartment,
                        size: 35,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.owner.ownerName,
                            style: TextStyle(
                              fontSize: isTablet ? 22 : 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.owner.collegeName,
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Admin Role",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              itemCount: features.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = features[index];

                return _buildActionButton(
                  icon: item['icon'],
                  title: item['title'],
                  color: item['color'],
                  onTap: () {
                    final navType navtype = item['navType'];
                    if (navtype == navType.push) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item['screen']),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => item['screen']),
                      );
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5568),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showOwnerInfo() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Icon(Icons.person, size: 70, color: Colors.blueAccent),
                const SizedBox(height: 12),

                Text(
                  widget.owner.ownerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),
                infoTile("College", widget.owner.collegeName),
                infoTile("Phone", widget.owner.ownerPhone),
                infoTile("Email", widget.owner.ownerEmail),
                infoTile("Address", widget.owner.collegeAddress),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget infoTile(String title, String value) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              "$title: ",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum navType { push, replace }
