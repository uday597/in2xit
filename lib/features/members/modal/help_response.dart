class HelpResponseModal {
  final int id;
  final int helpId;
  final int memberId;
  final String memberName;
  final String memberPhone;
  final String flatNo;
  final String response;
  final DateTime createdAt;

  HelpResponseModal({
    this.id = 0,
    required this.memberName,
    required this.memberPhone,
    required this.flatNo,
    required this.helpId,
    required this.memberId,
    required this.response,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'help_id': helpId,
      'member_id': memberId,
      'response': response,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HelpResponseModal.fromJson(Map<String, dynamic> json) {
    final m = json['members'] ?? {};

    return HelpResponseModal(
      id: json['id'] ?? 0,
      helpId: json['help_id'] ?? 0,
      memberId: json['member_id'] ?? 0,
      response: json['response'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      memberName: m['member_name'] ?? 'Unknown',
      memberPhone: m['member_phone'] ?? '',
      flatNo: m['flat_no'] ?? '',
    );
  }
}
