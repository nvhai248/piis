import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/pet.dart';
import '../pets/pet_form_screen.dart';
import '../../utils/message_utils.dart';

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;
  final VoidCallback onPetUpdated;

  const PetDetailsScreen({
    Key? key,
    required this.pet,
    required this.onPetUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pet.name,
          semanticsLabel: '${l10n.petName}: ${pet.name}',
        ),
        actions: [
          Semantics(
            button: true,
            label: l10n.editPet,
            child: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.editPet,
              onPressed: () async {
                final result = await Navigator.push<Pet>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetFormScreen(pet: pet),
                  ),
                );
                if (result != null) {
                  onPetUpdated();
                  if (context.mounted) {
                    MessageUtils.showMessage(
                      context,
                      message: l10n.petUpdatedSuccess,
                      type: MessageType.success,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Center(
              child: Hero(
                tag: 'pet_image_${pet.id}',
                child: Semantics(
                  label: pet.mainPicture != null ? '${pet.name} photo' : '${pet.name} placeholder icon',
                  image: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: pet.mainPicture != null
                        ? Image.network(
                            pet.mainPicture!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 200,
                              height: 200,
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.pets,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.pets,
                              size: 64,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pet Information
            _buildInfoSection(
              context,
              title: l10n.petType,
              value: pet.petType == PetType.other
                  ? pet.anotherPetType ?? l10n.otherPetType
                  : pet.petType.name,
              icon: Icons.category,
            ),

            _buildInfoSection(
              context,
              title: l10n.birthDate,
              value: pet.birthdayYear != null
                  ? '${pet.birthdayYear}-${pet.birthdayMonth}-${pet.birthdayDay}'
                  : '-',
              icon: Icons.calendar_today,
            ),

            if (pet.color != null && pet.color!.isNotEmpty)
              _buildInfoSection(
                context,
                title: l10n.color,
                value: pet.color!,
                icon: Icons.color_lens,
              ),

            if (pet.weight != null)
              _buildInfoSection(
                context,
                title: l10n.weight,
                value: '${pet.weight} kg',
                icon: Icons.monitor_weight,
              ),

            if (pet.height != null)
              _buildInfoSection(
                context,
                title: l10n.height,
                value: '${pet.height} cm',
                icon: Icons.height,
              ),

            if (pet.petClassify != null && pet.petClassify!.isNotEmpty)
              _buildInfoSection(
                context,
                title: l10n.breed,
                value: pet.petClassify!,
                icon: Icons.pets,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$title: $value',
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
                semanticLabel: title,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
