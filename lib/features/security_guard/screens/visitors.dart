import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_clone/features/members/modal/guest_modal.dart';
import 'package:my_gate_clone/features/members/providers/guest.dart';
import 'package:my_gate_clone/features/security_guard/modal/visitors.dart';
import 'package:my_gate_clone/features/security_guard/providers/visitor.dart';
import 'package:provider/provider.dart';

class VisitorsList extends StatefulWidget {
  final int societyId;
  const VisitorsList({super.key, required this.societyId});

  @override
  State<VisitorsList> createState() => _VisitorsListState();
}

class _VisitorsListState extends State<VisitorsList> {
  String searchQuery = "";
  bool showSearchBar = false;

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    Provider.of<RequestProvider>(
      context,
      listen: false,
    ).fetchRequests(widget.societyId);

    Provider.of<VisitorProvider>(
      context,
      listen: false,
    ).fetchVisitors(widget.societyId);
  }

  void resetFilter() {
    setState(() {
      selectedFilter = "All";
      selectedDate = null;
    });
  }

  void pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final visitorProvider = Provider.of<VisitorProvider>(context);

    /// Combine both lists
    List<dynamic> combinedList = [
      ...requestProvider.requests,
      ...visitorProvider.visitorList,
    ];

    List<dynamic> filteredList = combinedList.where((item) {
      final status = item.status.toLowerCase();

      // Helper function to check if status matches the selected filter
      bool statusMatch = selectedFilter == "All";

      if (selectedFilter.toLowerCase() == "approved") {
        statusMatch = status == "approved" || status == "in" || status == "out";
      } else if (selectedFilter.toLowerCase() == "pending") {
        statusMatch = status == "pending";
      } else if (selectedFilter.toLowerCase() == "rejected") {
        statusMatch = status == "rejected";
      }

      final String name = item is VisitorModal
          ? item.name.toLowerCase()
          : (item as GuestRequest).guestName.toLowerCase();
      bool searchMatch = searchQuery.isEmpty || name.contains(searchQuery);
      DateTime createdAt = item is VisitorModal
          ? item.createdAt
          : (item as GuestRequest).createdAt;
      bool dateMatch = true;
      if (selectedDate != null) {
        dateMatch =
            createdAt.year == selectedDate!.year &&
            createdAt.month == selectedDate!.month &&
            createdAt.day == selectedDate!.day;
      }
      return statusMatch && searchMatch && dateMatch;
    }).toList();

    /// Apply filter

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: Text(
          'Visitors List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showSearchBar = !showSearchBar;
                searchQuery = "";
              });
            },
            icon: Icon(showSearchBar ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () {
              pickDate();
            },
            icon: Icon(Icons.calendar_month),
          ),
          IconButton(onPressed: resetFilter, icon: Icon(Icons.refresh)),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSearchBar)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search visitor by name",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            /// Filter buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  filterChip("All"),
                  filterChip("approved"),
                  filterChip("pending"),
                  filterChip("rejected"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// LIST
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final visitor = filteredList[index];

                  /// IMAGE FIXED
                  String? image;
                  if (visitor is VisitorModal) {
                    image = visitor.image;
                  } else if (visitor is GuestRequest) {
                    image = visitor.guestImage;
                  }

                  /// DATE FIXED
                  final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
                      .format(
                        visitor is VisitorModal
                            ? visitor.createdAt
                            : (visitor as GuestRequest).createdAt,
                      );

                  return visitorCard(visitor, image, formattedDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter Chips
  Widget filterChip(String label) {
    return ChoiceChip(
      label: Text(label.toUpperCase()),
      selected: selectedFilter == label,
      onSelected: (value) {
        setState(() {
          selectedFilter = label;
        });
      },
    );
  }

  /// VISITOR Details method
  Widget visitorCard(dynamic visitor, String? image, String date) {
    final DateTime? inTime = visitor is VisitorModal
        ? visitor.inTime
        : (visitor as GuestRequest).inTime;

    final DateTime? outTime = visitor is VisitorModal
        ? visitor.outTime
        : (visitor as GuestRequest).outTime;

    final String name = (visitor is VisitorModal)
        ? visitor.name
        : (visitor as GuestRequest).guestName;

    final String phone = (visitor is VisitorModal)
        ? visitor.phone
        : (visitor as GuestRequest).guestPhone;

    final String Relative = (visitor is VisitorModal)
        ? visitor.relative
        : (visitor as GuestRequest).memberName.toString();
    final String flatNo = (visitor is VisitorModal)
        ? visitor.flatNo
        : (visitor as GuestRequest).memberFlatNo.toString();
    String approvalStatus = '';
    Color approvalColor = Colors.grey;

    // First, determine the approval status
    if (visitor.status == "approved" ||
        visitor.status == "in" ||
        visitor.status == "out") {
      approvalStatus = "Approved";
      approvalColor = Colors.green;
    } else if (visitor.status == "rejected") {
      approvalStatus = "Rejected";
      approvalColor = Colors.red;
    } else if (visitor.status == "pending") {
      approvalStatus = "Pending";
      approvalColor = Colors.orange;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// IMAGE
          Container(
            width: 90,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: (image != null && image.isNotEmpty)
                    ? NetworkImage(image)
                    : const AssetImage("assets/images/members.png")
                          as ImageProvider,
              ),
            ),
          ),

          const SizedBox(width: 15),

          /// TEXT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),
                Row(children: [Text('Relative:$Relative')]),
                const SizedBox(height: 4),

                /// PHONE
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(phone),
                  ],
                ),

                const SizedBox(height: 4),

                /// FLAT or ADDRESS
                Row(
                  children: [
                    const Icon(Icons.home, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(flatNo),
                  ],
                ),

                const SizedBox(height: 4),

                /// DATE
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(date),
                  ],
                ),

                const SizedBox(height: 6),
                if (inTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.login, size: 16, color: Colors.green),
                      const SizedBox(width: 5),
                      Text(
                        "IN: ${DateFormat('hh:mm a').format(inTime)}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],

                if (outTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.logout, size: 16, color: Colors.red),
                      const SizedBox(width: 5),
                      Text(
                        "OUT: ${DateFormat('hh:mm a').format(outTime)}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 5),

                /// APPROVAL STATUS (Always show pending/approved/rejected)

                /// Display approval status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: approvalColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    approvalStatus.toUpperCase(),
                    style: TextStyle(
                      color: approvalColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                /// ENTRY STATUS (if applicable - show separately)
                if (visitor.status == "in" || visitor.status == "out")
                  const SizedBox(height: 4),

                if (visitor.status == "in" || visitor.status == "out")
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (visitor.status == "in" ? Colors.blue : Colors.grey)
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      visitor.status == "in" ? "CHECKED IN" : "CHECKED OUT",
                      style: TextStyle(
                        color: visitor.status == "in"
                            ? Colors.blue
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                /// Buttons for IN / OUT (both Visitor & Guest)
                if ((visitor is VisitorModal && visitor.status == "approved") ||
                    (visitor is GuestRequest && visitor.status == "approved") ||
                    (visitor is VisitorModal && visitor.status == "in") ||
                    (visitor is GuestRequest && visitor.status == "in"))
                  Row(
                    children: [
                      /// IN Button - Show when status is "approved"
                      if ((visitor is VisitorModal &&
                              visitor.status == "approved") ||
                          (visitor is GuestRequest &&
                              visitor.status == "approved"))
                        ElevatedButton(
                          onPressed: () {
                            if (visitor is VisitorModal) {
                              context
                                  .read<VisitorProvider>()
                                  .updateVisitorStatus(visitor.id, "in");
                            } else if (visitor is GuestRequest) {
                              context.read<RequestProvider>().updateStatus(
                                id: visitor.id,
                                status: "in",
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text("CHECK IN"),
                        ),
                      const SizedBox(width: 10),

                      /// OUT Button - Show when status is "in"
                      if ((visitor is VisitorModal && visitor.status == "in") ||
                          (visitor is GuestRequest && visitor.status == "in"))
                        ElevatedButton(
                          onPressed: () {
                            if (visitor is VisitorModal) {
                              context
                                  .read<VisitorProvider>()
                                  .updateVisitorStatus(visitor.id, "out");
                            } else if (visitor is GuestRequest) {
                              context.read<RequestProvider>().updateStatus(
                                id: visitor.id,
                                status: "out",
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text("CHECK OUT"),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
