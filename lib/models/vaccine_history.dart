enum VaccineStatus {
  upcomming,
  completed,
  overdue;

  String get name => toString().split('.').last;

  static VaccineStatus fromString(String? value) {
    if (value == null) return VaccineStatus.upcomming;
    return VaccineStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => VaccineStatus.upcomming,
    );
  }
}

enum RecordedBy {
  DOCTOR,
  OWNER;

  String get name => toString().split('.').last;

  static RecordedBy fromString(String? value) {
    if (value == null) return RecordedBy.OWNER;
    return RecordedBy.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RecordedBy.OWNER,
    );
  }
}

enum VaccineType {
  ONE_TIME,
  REPEAT;

  String get name => toString().split('.').last;

  static VaccineType fromString(String? value) {
    if (value == null) return VaccineType.ONE_TIME;
    return VaccineType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => VaccineType.ONE_TIME,
    );
  }
}

class VaccineHistory {
  final String id;
  final String petId;
  final String name;
  final String? description;
  final DateTime dateOfVaccine;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int quantity;
  final int price;
  final String? brand;
  final String? place;
  final VaccineType type;
  final RecordedBy recordedBy;
  final VaccineStatus status;
  final int? reminderTime;

  VaccineHistory({
    required this.id,
    required this.petId,
    required this.name,
    this.description,
    required this.dateOfVaccine,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    required this.quantity,
    required this.price,
    this.brand,
    this.place,
    required this.type,
    required this.recordedBy,
    required this.status,
    this.reminderTime,
  });

  factory VaccineHistory.fromJson(Map<String, dynamic> json) {
    try {
      return VaccineHistory(
        id: json['id'] as String,
        petId: json['pet_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        dateOfVaccine: DateTime.parse(json['date_of_vaccine'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        isDeleted: json['is_deleted'] as bool? ?? false,
        quantity: json['quantity'] as int? ?? 1,
        price: json['price'] as int? ?? 0,
        brand: json['brand'] as String?,
        place: json['place'] as String?,
        type: VaccineType.fromString(json['type'] as String?),
        recordedBy: RecordedBy.fromString(json['recorded_by'] as String?),
        status: VaccineStatus.fromString(json['status'] as String?),
        reminderTime: json['reminder_time'] as int?,
      );
    } catch (e) {
      print('Error parsing VaccineHistory: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'name': name,
      'description': description,
      'date_of_vaccine': dateOfVaccine.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'quantity': quantity,
      'price': price,
      'brand': brand,
      'place': place,
      'type': type.name,
      'recorded_by': recordedBy.name,
      'status': status.name,
      'reminder_time': reminderTime,
    };
  }

  VaccineHistory copyWith({
    String? id,
    String? petId,
    String? name,
    String? description,
    DateTime? dateOfVaccine,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? quantity,
    int? price,
    String? brand,
    String? place,
    VaccineType? type,
    RecordedBy? recordedBy,
    VaccineStatus? status,
    int? reminderTime,
  }) {
    return VaccineHistory(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      description: description ?? this.description,
      dateOfVaccine: dateOfVaccine ?? this.dateOfVaccine,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      quantity: quantity ?? this.quantity,
      brand: brand ?? this.brand,
      place: place ?? this.place,
      price: price ?? this.price,
      type: type ?? this.type,
      recordedBy: recordedBy ?? this.recordedBy,
      status: status ?? this.status,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
