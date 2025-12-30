class StudentModal {
  final int id;
  final int collegeId;
  final String name;
  final String className;
  final String mobile;
  final String address;
  final String? studentImage;
  final String? qrCode;
  final DateTime createdAt;
  final String? college_name;
  StudentModal({
    required this.id,
    required this.collegeId,
    required this.name,
    required this.className,
    required this.mobile,
    required this.address,
    required this.createdAt,
    this.studentImage,
    this.qrCode,
    this.college_name,
  });

  factory StudentModal.fromMap(Map<String, dynamic> map) {
    return StudentModal(
      id: map['id'],
      collegeId: map['college_id'] is Map
          ? map['college_id']['id']
          : map['college_id'],
      name: map['name'],
      className: map['class_name'],
      mobile: map['mobile'],
      address: map['address'],
      studentImage: map['student_image'],
      qrCode: map['qr_code'],
      createdAt: DateTime.parse(map['created_at']),
      college_name: map['college_id'] is Map
          ? map['college_id']['college_name']
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'college_id': collegeId,
      'name': name,
      'class_name': className,
      'mobile': mobile,
      'address': address,
      'student_image': studentImage,
      'qr_code': qrCode,
    };
  }
}
