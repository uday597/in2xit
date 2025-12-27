import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/admin/provider/society_provider.dart';
import 'package:provider/provider.dart';

class ContactUs extends StatefulWidget {
  final int societyId;
  const ContactUs({super.key, required this.societyId});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocietyProvider>(
        context,
        listen: false,
      ).fetchCurrentSociety(widget.societyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocietyProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = provider.crruntSociety;
    if (data == null) {
      return const Scaffold(body: Center(child: Text("No society found")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],

                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/gate.png'),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    data.collegeName,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Get in touch with us",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  buildInfoCard(
                    title: "Society Name",
                    value: data.collegeName,
                    icon: Icons.person,
                  ),
                  buildInfoCard(
                    title: "Owner Name",
                    value: data.ownerName,
                    icon: Icons.person,
                  ),
                  buildInfoCard(
                    title: "Owner Number",
                    value: data.ownerPhone,
                    icon: Icons.phone,
                  ),
                  buildInfoCard(
                    title: "Email Address",
                    value: data.ownerEmail,
                    icon: Icons.email,
                  ),
                  buildInfoCard(
                    title: "Address",
                    value: data.collegeAddress,
                    icon: Icons.location_on,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "For any emergency or enquiry, you can reach out to the owner or management team.\nWe are here to help and ensure smooth experience inside society.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
