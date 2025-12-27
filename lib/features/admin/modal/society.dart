class CollegeModal {
  final int id;
  final String collegeName;
  final String collegePassword;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final String collegeAddress;
  final String pincode;
  final String city;
  final String state;
  final String total_towers;
  final String total_flats;
  final String? fcmToken;

  CollegeModal({
    required this.id,
    required this.collegeName,
    required this.collegePassword,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.collegeAddress,
    required this.pincode,
    required this.city,
    required this.state,
    required this.total_flats,
    required this.total_towers,
    this.fcmToken,
  });

  // From Supabase map
  factory CollegeModal.fromMap(Map<String, dynamic> data) {
    return CollegeModal(
      id: data['id'],
      pincode: data['pincode'],
      city: data['city'],
      state: data['state'],
      total_flats: data['total_flat'],
      total_towers: data['total_towers'],
      collegeName: data['college_name'],
      collegePassword: data['college_password'],
      ownerName: data['owner_name'],
      ownerPhone: data['owner_phone'],
      ownerEmail: data['owner_email'],
      collegeAddress: data['college_address'],
      fcmToken: data['fcm_token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pincode': pincode,
      'city': city,
      'state': state,
      'total_flat': total_flats,
      'total_towers': total_towers,
      'college_name': collegeName,
      'college_password': collegePassword,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'owner_email': ownerEmail,
      'college_address': collegeAddress,
      'fcm_token': fcmToken,
    };
  }
}
