import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/members_provider.dart';
import 'package:my_gate_clone/features/owner/screens/edit_member.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class MembersListScreen extends StatefulWidget {
  final int societyId;
  const MembersListScreen({super.key, required this.societyId});

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  late Future fetchFuture;

  @override
  void initState() {
    super.initState();
    fetchFuture = Provider.of<MembersProvider>(
      context,
      listen: false,
    ).fatchMembersList(widget.societyId);
  }

  @override
  Widget build(BuildContext context) {
    final membersProvider = Provider.of<MembersProvider>(context);

    return Scaffold(
      appBar: reuseAppBar(title: 'Members List'),
      backgroundColor: const Color(0xffF8F9FA),

      body: FutureBuilder(
        future: fetchFuture,
        builder: (context, snapshot) {
          if (membersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (membersProvider.members.isEmpty) {
            return const Center(child: Text("No members found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: membersProvider.members.length,
            itemBuilder: (context, index) {
              final member = membersProvider.members[index];

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
                  contentPadding: const EdgeInsets.all(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditMemberInfo(memberId: member.id),
                      ),
                    );
                  },

                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        (member.memberImage != null &&
                            member.memberImage!.startsWith("http"))
                        ? NetworkImage(member.memberImage!)
                        : const AssetImage("assets/default_avatar.png")
                              as ImageProvider,
                  ),

                  title: Text(
                    member.memberName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "Flat: ${member.memberFlatNo}",
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.blueAccent,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
