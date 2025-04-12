class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String icon;
  final String backgroundColor;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.features,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.icon,
    required this.backgroundColor,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      features: List<String>.from(json['features']),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      icon: json['icon'] ?? '',
      backgroundColor: json['background_color'] ?? '0xFF000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'features': features,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'icon': icon,
      'background_color': backgroundColor,
    };
  }
} 