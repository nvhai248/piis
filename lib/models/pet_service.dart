class PetService {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String duration;
  final double rating;
  final int reviewCount;

  PetService({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.duration,
    required this.rating,
    required this.reviewCount,
  });

  factory PetService.fromJson(Map<String, dynamic> json) {
    return PetService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'duration': duration,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
} 