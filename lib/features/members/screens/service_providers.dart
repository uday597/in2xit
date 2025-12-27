import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/owner/modal/service_provider.dart';
import 'package:my_gate_clone/features/owner/provider/service_provider.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class MemberServiceProvidersScreen extends StatefulWidget {
  final int societyId;
  const MemberServiceProvidersScreen({super.key, required this.societyId});

  @override
  State<MemberServiceProvidersScreen> createState() =>
      _MemberServiceProvidersScreenState();
}

class _MemberServiceProvidersScreenState
    extends State<MemberServiceProvidersScreen> {
  String selectedCategory = "All";
  final categories = ["All", "Plumber", "Electrician", "Carpenter", "Painter"];
  String searchQuery = "";

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
      body: Consumer<ServiceProviders>(
        builder: (context, controller, _) {
          List<ServiceProviderModal> filteredList = controller.servicesList
              .where(
                (provider) =>
                    (selectedCategory == "All" ||
                        provider.category == selectedCategory) &&
                    provider.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search services...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => searchQuery = val),
                ),
              ),

              // Category Chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: const Color.fromARGB(239, 7, 7, 13),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Provider List
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredList.isEmpty
                    ? const Center(child: Text("No providers found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final provider = filteredList[index];
                          return GestureDetector(
                            onTap: () => showProviderDetails(provider),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2196F3),
                                    const Color(0xFF1A237E),
                                  ],

                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      provider.category,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          provider.phone,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            provider.address,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showProviderDetails(ServiceProviderModal provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  provider.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                infoRow(Icons.category, "Category", provider.category),
                infoRow(Icons.phone, "Phone", provider.phone),
                infoRow(Icons.home, "Address", provider.address),
                infoRow(
                  Icons.access_time,
                  "Available Time",
                  provider.availableTime,
                ),
                if (provider.experience != null)
                  infoRow(Icons.star, "Experience", provider.experience!),
                infoRow(Icons.attach_money, "Charges", provider.charges),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4286F4)),
          const SizedBox(width: 10),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
