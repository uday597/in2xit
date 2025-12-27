import 'package:flutter/material.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // screen size [web:6]
    final width = size.width;

    // breakpoints
    int crossAxisCount;
    double titleFontSize;
    double cardAspectRatio;
    EdgeInsets gridPadding;

    if (width < 600) {
      // mobile
      crossAxisCount = 2;
      titleFontSize = 26;
      cardAspectRatio = 0.85;
      gridPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    } else if (width < 900) {
      // small tablet
      crossAxisCount = 3;
      titleFontSize = 30;
      cardAspectRatio = 0.9;
      gridPadding = const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
    } else {
      // large tablet / web
      crossAxisCount = 4;
      titleFontSize = 32;
      cardAspectRatio = 1.0;
      gridPadding = const EdgeInsets.symmetric(horizontal: 80, vertical: 40);
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],

            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: gridPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  "Select Your Role",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: cardAspectRatio,
                    children: [
                      roleCard("Admin", "assets/images/admin.png", () {
                        Navigator.pushNamed(context, '/addsociety');
                      }),
                      roleCard("Admin", "assets/images/owner.png", () {
                        Navigator.pushNamed(context, '/ownerlogin');
                      }),
                      roleCard("Members", "assets/images/members.png", () {
                        Navigator.pushNamed(context, '/memberlogin');
                      }),
                      roleCard(
                        "Security Guard",
                        "assets/images/security.png",
                        () {
                          Navigator.pushNamed(context, '/guardlogin');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget roleCard(String title, String imagePath, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFE3F2FD)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(imagePath, height: 80, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
