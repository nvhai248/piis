class PetCare {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String website;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool isOpen;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetCare({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.website,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.isOpen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetCare.fromJson(Map<String, dynamic> json) {
    return PetCare(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      services: List<String>.from(json['services']),
      rating: json['rating'].toDouble(),
      reviewCount: json['review_count'],
      imageUrl: json['image_url'],
      isOpen: json['is_open'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'services': services,
      'rating': rating,
      'review_count': reviewCount,
      'image_url': imageUrl,
      'is_open': isOpen,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 