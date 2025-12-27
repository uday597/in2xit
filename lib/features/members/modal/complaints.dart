class ComplaintsModal {
  final int? id;
  final int memberId;
  final String? image;
  final String title;
  final String description;
  final DateTime createdAt;

  final String memberName;
  final String? memberImage;
  final String? memberPhone;
  final String? flatNo;

  ComplaintsModal({
    this.id,
    required this.memberId,
    required this.title,
    this.image,
    required this.description,
    required this.createdAt,
    required this.memberName,
    this.memberImage,
    this.memberPhone,
    this.flatNo,
  });

  factory ComplaintsModal.fromMap(Map<String, dynamic> data) {
    return ComplaintsModal(
      id: data['id'],
      memberId: data['member_id'],
      title: data['title'],
      description: data['description'],
      image: data['image'],
      createdAt: DateTime.parse(data['created_at']),
      memberName: data['members']?['member_name'] ?? 'Unknown',
      memberImage: data['members']?['profile_image'],
      memberPhone: data['members']?['member_phone'],
      flatNo: data['members']?['flat_no'],
    );
  }
}
