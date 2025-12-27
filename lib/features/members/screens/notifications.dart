import 'package:flutter/material.dart';
import 'package:my_gate_clone/utilis/appbar.dart';

class MemberNotificationsScreen extends StatelessWidget {
  MemberNotificationsScreen({super.key});

  final List<MemberNotification> notifications = [
    MemberNotification(
      icon: Icons.directions_walk,
      title: "Visitor Arrived",
      description: "Rahul is waiting at the main gate",
      time: "2 min ago",
      isRead: false,
    ),
    MemberNotification(
      icon: Icons.campaign,
      title: "Society Announcement",
      description: "Water supply will be off from 2PM - 5PM",
      time: "1 hr ago",
      isRead: false,
    ),
    MemberNotification(
      icon: Icons.warning_amber_rounded,
      title: "Emergency Alert",
      description: "Fire drill scheduled at 6 PM today",
      time: "Today",
      isRead: true,
    ),
    MemberNotification(
      icon: Icons.payments,
      title: "Maintenance Reminder",
      description: "Your maintenance payment is due",
      time: "Yesterday",
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: reuseAppBar(title: 'Notifications'),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _notificationTile(notification);
        },
      ),
    );
  }

  Widget _notificationTile(MemberNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade100,
            child: Icon(notification.icon, color: Colors.blue.shade800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      notification.time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemberNotification {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final bool isRead;

  MemberNotification({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
  });
}
