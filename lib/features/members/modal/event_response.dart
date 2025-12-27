class EventResponseModal {
  final int id;
  final int eventId;
  final int memberId;
  final String type;
  final String? comment;
  final DateTime createdAt;

  final String memberName;
  final String? memberImage;

  EventResponseModal({
    required this.id,
    required this.eventId,
    required this.memberId,
    required this.type,
    this.comment,
    required this.createdAt,
    required this.memberName,
    this.memberImage,
  });

  factory EventResponseModal.fromMap(Map<String, dynamic> data) {
    return EventResponseModal(
      id: data['id'],
      eventId: data['event_id'],
      memberId: data['member_id'],
      type: data['type'],
      comment: data['comment'],
      createdAt: DateTime.parse(data['created_at']),
      memberName: data['members']?['member_name'] ?? 'Member',
      memberImage: data['members']?['profile_image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'member_id': memberId,
      'type': type,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'member_name': memberName,
      'profile_image': memberImage,
    };
  }
}
