class PaymentModal {
  final int id;
  final int societyId;
  final int memberId;
  final double amount;
  final String reason;
  final String? paymentImage;
  final String status;
  final String createdAt;
  final String? memberName;
  final String? memberPhone;
  final String? flatNo;

  PaymentModal({
    required this.id,
    required this.societyId,
    required this.memberId,
    required this.amount,
    required this.reason,
    this.paymentImage,
    required this.status,
    required this.createdAt,
    this.memberName,
    this.memberPhone,
    this.flatNo,
  });

  factory PaymentModal.fromMap(Map<String, dynamic> map) {
    return PaymentModal(
      id: map['id'],
      societyId: map['society_id'],
      memberId: map['member_id'],
      amount: double.parse(map['amount'].toString()),
      reason: map['reason'],
      paymentImage: map['payment_image'],
      status: map['status'],
      createdAt: map['created_at'],
      memberName: map['members']?['member_name'],
      memberPhone: map['members']?['member_phone'],
      flatNo: map['members']?['flat_no'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'society_id': societyId,
      'member_id': memberId,
      'amount': amount,
      'reason': reason,
      'payment_image': paymentImage,
      'status': status,
    };
  }
}
