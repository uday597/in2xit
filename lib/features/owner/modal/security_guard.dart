class SecurityGuardModal {
  final int id;
  final int societyId;
  final String name;
  final String phone;
  final String address;
  final String idProof;
  final String dob;
  final String gender;
  final String? societyName;
  final String? profileImage;
  final String? createdAt;
  final String? fcmToken;

  SecurityGuardModal({
    required this.id,
    required this.societyId,
    this.societyName,
    required this.name,
    required this.dob,
    required this.idProof,
    required this.gender,
    required this.phone,
    required this.address,
    this.profileImage,
    this.createdAt,
    this.fcmToken,
  });

  factory SecurityGuardModal.fromMap(Map<String, dynamic> map) {
    return SecurityGuardModal(
      id: map['id'],
      dob: map['dob'],
      gender: map['gender'],
      idProof: map['id_proof'],
      societyId: map['society_id'],
      societyName: map['societies']?['society_name'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      profileImage: map['profile_image'],
      createdAt: map['created_at'],
      fcmToken: map['fcm_token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'society_id': societyId,
      'name': name,
      'phone': phone,
      'address': address,
      'dob': dob,
      'id_proof': idProof,
      'gender': gender,
      'profile_image': profileImage,
      'created_at': createdAt,
      'fcm_token': fcmToken,
    };
  }
}
