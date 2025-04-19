import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/pet.dart';
import '../../widgets/info_section.dart';
import 'widgets/pet_image.dart';

class PetDetailsSection extends StatelessWidget {
  final Pet pet;

  const PetDetailsSection({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PetImage(pet: pet),
        const SizedBox(height: 24),
        InfoSection(
          title: l10n.petType,
          value: pet.petType == PetType.other
              ? pet.anotherPetType ?? l10n.otherPetType
              : pet.petType.name,
          icon: Icons.category,
        ),
        InfoSection(
          title: l10n.birthDate,
          value: pet.birthdayYear != null
              ? '${pet.birthdayYear}-${pet.birthdayMonth}-${pet.birthdayDay}'
              : '-',
          icon: Icons.calendar_today,
        ),
        if (pet.color != null && pet.color!.isNotEmpty)
          InfoSection(
            title: l10n.color,
            value: pet.color!,
            icon: Icons.color_lens,
          ),
        if (pet.weight != null)
          InfoSection(
            title: l10n.weight,
            value: '${pet.weight} kg',
            icon: Icons.monitor_weight,
          ),
        if (pet.height != null)
          InfoSection(
            title: l10n.height,
            value: '${pet.height} cm',
            icon: Icons.height,
          ),
        if (pet.petClassify != null && pet.petClassify!.isNotEmpty)
          InfoSection(
            title: l10n.breed,
            value: pet.petClassify!,
            icon: Icons.pets,
          ),
      ],
    );
  }
} 