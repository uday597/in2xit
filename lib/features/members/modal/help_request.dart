class HelpModal {
  final int id;
  final int societyId;
  final int memberId;
  final String type;
  final String description;
  final DateTime createdAt;
  final String memberName;
  final String memberPhone;
  final String memberFlat;

  HelpModal({
    this.id = 0,
    required this.societyId,
    required this.memberId,
    required this.type,
    required this.description,
    required this.createdAt,
    required this.memberName,
    required this.memberPhone,
    required this.memberFlat,
  });

  factory HelpModal.fromJson(Map<String, dynamic> json) {
    final m = json['members'] ?? {};

    return HelpModal(
      id: json['id'],
      societyId: json['society_id'],
      memberId: json['member_id'],
      type: json['type'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      memberName: m['member_name'] ?? "Unknown",
      memberPhone: m['member_phone'] ?? "",
      memberFlat: m['flat_no'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'society_id': societyId,
      'member_id': memberId,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
