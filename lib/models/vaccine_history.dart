enum VaccineStatus {
  upcoming,
  completed,
  overdue;

  String get name => toString().split('.').last;

  static VaccineStatus fromString(String? value) {
    if (value == null) return VaccineStatus.upcoming;

    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'upcoming':
      case 'upcomming':
      case 'pending':
        return VaccineStatus.upcoming;
      case 'completed':
      case 'done':
      case 'finished':
        return VaccineStatus.completed;
      case 'overdue':
      case 'late':
      case 'expired':
        return VaccineStatus.overdue;
      default:
        return VaccineStatus.upcoming;
    }
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
    this.createdAt,
    this.updatedAt,
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
        id: json['id']?.toString() ?? '',
        petId: json['pet_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        dateOfVaccine: json['date_of_vaccine'] != null 
            ? DateTime.parse(json['date_of_vaccine'].toString())
            : DateTime.now(),
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'].toString())
            : null,
        isDeleted: json['is_deleted'] as bool? ?? false,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toInt() ?? 0,
        brand: json['brand']?.toString(),
        place: json['place']?.toString(),
        type: VaccineType.fromString(json['type']?.toString()),
        recordedBy: RecordedBy.fromString(json['recorded_by']?.toString()),
        status: VaccineStatus.fromString(json['status']?.toString()),
        reminderTime: (json['reminder_time'] as num?)?.toInt(),
      );
    } catch (e, stackTrace) {
      print('Error parsing VaccineHistory: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'pet_id': petId,
      'name': name,
      'description': description,
      'date_of_vaccine': dateOfVaccine.toIso8601String(),
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

    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();

    return data;
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
      price: price ?? this.price,
      brand: brand ?? this.brand,
      place: place ?? this.place,
      type: type ?? this.type,
      recordedBy: recordedBy ?? this.recordedBy,
      status: status ?? this.status,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
