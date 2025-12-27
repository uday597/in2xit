class MembersModal {
  final int id;
  final int societyId;
  final String memberName;
  final String memberEmail;
  final String memberPhone;
  final String memberAddress;
  final String? memberImage;
  final String memberFlatNo;
  final String tower;
  final String totalVehicle;
  final String vehicleNo;
  final String dob;
  final String gender;
  final String idProof;
  final String? fcmToken;
  MembersModal({
    required this.id,
    required this.societyId,
    required this.memberEmail,
    required this.memberAddress,
    required this.memberFlatNo,
    this.memberImage,
    required this.dob,
    required this.gender,
    required this.vehicleNo,
    required this.totalVehicle,
    required this.tower,
    required this.idProof,
    required this.memberName,
    required this.memberPhone,
    this.fcmToken,
  });
  factory MembersModal.fromMap(Map<String, dynamic> data) {
    return MembersModal(
      id: data['id'],
      societyId: data['society_id'],
      memberEmail: data['member_email'],
      memberAddress: data['member_address'],
      memberFlatNo: data['flat_no'],
      memberImage: data['profile_image'],
      memberName: data['member_name'],
      memberPhone: data['member_phone'],
      dob: data['dob'],
      vehicleNo: data['vehicle_no'],
      totalVehicle: data['vehicle_count'],
      gender: data['gender'],
      idProof: data['id_proof'],
      tower: data['tower'],
      fcmToken: data['fcm_token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'society_id': societyId,
      'member_name': memberName,
      'member_email': memberEmail,
      'member_phone': memberPhone,
      'member_address': memberAddress,
      'flat_no': memberFlatNo,
      'profile_image': memberImage,
      'dob': dob,
      'tower': tower,
      'vehicle_count': totalVehicle,
      'vehicle_no': vehicleNo,
      'gender': gender,
      'id_proof': idProof,
      'fcm_token': fcmToken,
    };
  }
}
