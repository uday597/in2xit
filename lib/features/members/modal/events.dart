class EventsModal {
  final int id;
  final String title;
  final String description;
  final String? image;
  final int societyId;
  final int memberId;
  final String visibility; // 'public' or 'selective'
  final String? visibleTo; // comma-separated member IDs
  final DateTime createdAt;
  final String memberName;
  final String memberImage;
  final DateTime updatedAt;

  EventsModal({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.societyId,
    required this.memberId,
    this.visibility = 'public',
    this.visibleTo,
    required this.memberName,
    required this.memberImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventsModal.fromMap(Map<String, dynamic> data) {
    return EventsModal(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      image: data['image'],
      societyId: data['society_id'],
      memberId: data['member_id'],
      visibility: data['visibility'] ?? 'public',
      visibleTo: data['visible_to'],
      memberName: data['members']?['member_name'] ?? 'Member',
      memberImage: data['members']?['profile_image'] ?? '',
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'society_id': societyId,
      'member_id': memberId,
      'visibility': visibility,
      'visible_to': visibleTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  List<int> get selectedMemberIds {
    if (visibleTo == null || visibleTo!.isEmpty) return [];
    return visibleTo!
        .split(',')
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();
  }
}
