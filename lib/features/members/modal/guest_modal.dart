class GuestRequest {
  final int id;
  final int societyId;
  final int memberId;
  final String guestName;
  final String guestPhone;
  final String? guestAddress;
  final String? guestImage;
  final String? qrCode;
  final String? memberName;
  final String? memberFlatNo;
  final String? request_type;
  final DateTime? inTime;
  final DateTime? outTime;

  final DateTime createdAt;
  final DateTime? guardViewedAt;
  final DateTime? guardActionAt;
  final String status;

  GuestRequest({
    required this.id,
    this.inTime,
    this.outTime,
    this.memberName,
    this.memberFlatNo,
    required this.societyId,
    required this.memberId,
    required this.guestName,
    required this.guestPhone,
    this.guestAddress,
    this.guestImage,
    this.qrCode,
    required this.createdAt,
    this.guardViewedAt,
    this.guardActionAt,
    required this.status,
    required this.request_type,
  });

  factory GuestRequest.fromMap(Map<String, dynamic> map) {
    return GuestRequest(
      id: map['id'],
      societyId: map['society_id'],
      memberId: map['member_id'],
      request_type: map['request_type'],
      memberName: map['members']?['member_name'] ?? 'Unknown',
      memberFlatNo: map['members']?['flat_no'] ?? 'no data',
      inTime: map['in_time'] != null ? DateTime.parse(map['in_time']) : null,

      outTime: map['out_time'] != null ? DateTime.parse(map['out_time']) : null,

      guestName: map['guest_name'],
      guestPhone: map['guest_phone'],
      guestAddress: map['guest_address'],
      guestImage: map['guest_image'],
      qrCode: map['qr_code'],
      createdAt: DateTime.parse(map['created_at']),
      guardViewedAt: map['guard_viewed_at'] != null
          ? DateTime.parse(map['guard_viewed_at'])
          : null,
      guardActionAt: map['guard_action_at'] != null
          ? DateTime.parse(map['guard_action_at'])
          : null,
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'in_time': inTime?.toIso8601String(),
      'out_time': outTime?.toIso8601String(),

      'id': id,
      'society_id': societyId,
      'member_id': memberId,
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'member_name': memberName,
      'guest_address': guestAddress,
      'guest_image': guestImage,
      'status': status,
      'qr_code': qrCode,
      'request_type': request_type,
      'created_at': createdAt.toIso8601String(),
      'guard_viewed_at': guardViewedAt?.toIso8601String(),
      'guard_action_at': guardActionAt?.toIso8601String(),
    };
  }
}

extension GuestRequestExtension on GuestRequest {
  String get type => request_type ?? 'guest';
}
