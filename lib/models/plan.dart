enum PlanStatus {
  active,
  inactive,
  expired,
  cancelled
}

class Plan {
  final String id;
  final String userId;
  final String name;
  final String description;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final PlanStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plan({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: PlanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PlanStatus.inactive,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 