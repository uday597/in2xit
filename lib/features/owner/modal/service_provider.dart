class ServiceProviderModal {
  final int id;
  final int societyId;
  final String name;
  final String phone;
  final String category;
  final String address;
  final String? experience;
  final String charges;
  final String availableTime;
  final String createdAt;

  ServiceProviderModal({
    required this.id,
    required this.societyId,
    required this.name,
    required this.phone,
    required this.category,
    required this.address,
    this.experience,
    required this.charges,
    required this.availableTime,
    required this.createdAt,
  });

  factory ServiceProviderModal.fromMap(Map<String, dynamic> data) {
    return ServiceProviderModal(
      id: data['id'],
      societyId: data['society_id'],
      name: data['name'],
      phone: data['phone'],
      category: data['category'],
      createdAt: data['created_at'],
      address: data['address'],
      availableTime: data['available_time'], // fixed spelling
      charges: data['charges'],
      experience: data['experience'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'society_id': societyId,
      'name': name,
      'phone': phone,
      'category': category,
      'address': address,
      'experience': experience,
      'charges': charges,
      'available_time': availableTime,
    };
  }
}
