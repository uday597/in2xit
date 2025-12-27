import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/security_guard.dart';
import 'package:my_gate_clone/features/owner/screens/edit_securityGuard.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class GuardsList extends StatefulWidget {
  final int societyId;
  const GuardsList({super.key, required this.societyId});

  @override
  State<GuardsList> createState() => _GuardsListState();
}

class _GuardsListState extends State<GuardsList> {
  @override
  void initState() {
    super.initState();
    Provider.of<SecurityGuardProvider>(
      context,
      listen: false,
    ).fetchGuards(widget.societyId);
  }

  @override
  Widget build(BuildContext context) {
    final guardProvider = Provider.of<SecurityGuardProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: 'Security Guards'),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: guardProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : guardProvider.guards.isEmpty
                ? const Center(
                    child: Text(
                      "No Guards Found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: guardProvider.guards.length,
                    itemBuilder: (context, index) {
                      final guard = guardProvider.guards[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditSecurityGuardScreen(guard: guard),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                guard.profileImage != null &&
                                    guard.profileImage!.isNotEmpty
                                ? NetworkImage(guard.profileImage!)
                                : null,
                            child:
                                guard.profileImage == null ||
                                    guard.profileImage!.isEmpty
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          title: Text(
                            guard.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            guard.phone,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
