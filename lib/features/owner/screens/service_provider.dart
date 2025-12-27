import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/provider/service_provider.dart';
import 'package:my_gate_clone/features/owner/screens/add_services.dart';
import 'package:my_gate_clone/features/owner/screens/view_serviceProvider.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class ProvidersListScreen extends StatefulWidget {
  final int societyId;
  const ProvidersListScreen({super.key, required this.societyId});

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProviders>(
        context,
        listen: false,
      ).fetchServices(widget.societyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: reuseAppBar(title: 'Service Providers'),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Services',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProviderScreen(societyId: widget.societyId),
            ),
          );
        },
      ),

      body: Consumer<ServiceProviders>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.servicesList.isEmpty) {
            return const Center(
              child: Text(
                "No providers added yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.servicesList.length,
            itemBuilder: (_, index) {
              final p = controller.servicesList[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    p.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(p.category),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        spacing: 3,
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.white,
                          ),
                          Text(p.phone, style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewProviderScreen(provider: p),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
