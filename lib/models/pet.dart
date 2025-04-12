enum PetStatus { ACTIVE, PASS_AWAY }

enum PetType { dog, cat, bird, fish, reptile, hamster, other }

class Pet {
  final String id;
  final DateTime createdAt;
  final String name;
  final String? mainPicture;
  final String? color;
  final int? birthdayYear;
  final int? birthdayMonth;
  final int? birthdayDay;
  final String? qrCodeUrl;
  final String userId;
  final PetStatus status;
  final int? weight;
  final int? height;
  final String? petClassify;
  final PetType petType;
  final String? anotherPetType;

  const Pet({
    required this.id,
    required this.createdAt,
    required this.name,
    this.mainPicture,
    this.color,
    this.birthdayYear,
    this.birthdayMonth,
    this.birthdayDay,
    this.qrCodeUrl,
    required this.userId,
    this.status = PetStatus.ACTIVE,
    this.weight,
    this.height,
    this.petClassify,
    required this.petType,
    this.anotherPetType,
  });

  String get imageUrl => mainPicture ?? 'assets/images/default_pet.png';

  String get displayType {
    if (anotherPetType != null) {
      return anotherPetType!;
    }
    return petType.name[0].toUpperCase() + petType.name.substring(1);
  }

  DateTime? get birthday {
    if (birthdayYear == null || birthdayMonth == null || birthdayDay == null) {
      return null;
    }
    return DateTime(birthdayYear!, birthdayMonth!, birthdayDay!);
  }

  int? get ageInMonths {
    if (birthday == null) return null;
    final now = DateTime.now();
    return ((now.year - birthday!.year) * 12) + (now.month - birthday!.month);
  }

  String get ageDisplay {
    final months = ageInMonths;
    if (months == null) return 'Age unknown';
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) return '$years years';
    return '$years years, $remainingMonths months';
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String,
      mainPicture: json['main_picture'] as String?,
      color: json['color'] as String?,
      birthdayYear: json['birthday_year'] as int?,
      birthdayMonth: json['birthday_month'] as int?,
      birthdayDay: json['birthday_day'] as int?,
      qrCodeUrl: json['qr_code_url'] as String?,
      userId: json['user_id'] as String,
      status: PetStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => PetStatus.ACTIVE,
      ),
      weight: json['weight'] as int?,
      height: json['height'] as int?,
      petClassify: json['pet_classify'] as String?,
      petType: PetType.values.firstWhere(
        (e) => e.name == (json['pet_type'] as String),
        orElse: () => PetType.dog,
      ),
      anotherPetType: json['another_pet_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'main_picture': mainPicture,
      'color': color,
      'birthday_year': birthdayYear,
      'birthday_month': birthdayMonth,
      'birthday_day': birthdayDay,
      'qr_code_url': qrCodeUrl,
      'user_id': userId,
      'status': status.name,
      'weight': weight,
      'height': height,
      'pet_classify': petClassify,
      'pet_type': petType.name,
      'another_pet_type': anotherPetType,
    };
  }

  Pet copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? mainPicture,
    String? color,
    int? birthdayYear,
    int? birthdayMonth,
    int? birthdayDay,
    String? qrCodeUrl,
    String? userId,
    PetStatus? status,
    int? weight,
    int? height,
    String? petClassify,
    PetType? petType,
    String? anotherPetType,
  }) {
    return Pet(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      mainPicture: mainPicture ?? this.mainPicture,
      color: color ?? this.color,
      birthdayYear: birthdayYear ?? this.birthdayYear,
      birthdayMonth: birthdayMonth ?? this.birthdayMonth,
      birthdayDay: birthdayDay ?? this.birthdayDay,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      petClassify: petClassify ?? this.petClassify,
      petType: petType ?? this.petType,
      anotherPetType: anotherPetType ?? this.anotherPetType,
    );
  }
}