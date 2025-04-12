import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final petService = PetService(supabase: Supabase.instance.client);

    return Scaffold(
      body: StreamBuilder<List<Pet>>(
        stream: petService.streamUserPets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading pets',
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // This will rebuild the StreamBuilder
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final pets = snapshot.data!;

          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.addPet,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add pet screen
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addPet),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: pet.mainPicture != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  pet.mainPicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPetIcon(context, pet.petType);
                                  },
                                ),
                              )
                            : _buildPetIcon(context, pet.petType),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pet.displayType} • ${pet.ageDisplay}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildChip(context, l10n.petType, pet.displayType),
                                if (pet.petClassify != null) ...[
                                  const SizedBox(width: 8),
                                  _buildChip(context, l10n.petBreed, pet.petClassify!),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          // TODO: Navigate to edit pet screen
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add pet screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPetIcon(BuildContext context, PetType type) {
    IconData icon;
    switch (type) {
      case PetType.dog:
        icon = Icons.pets;
        break;
      case PetType.cat:
        icon = Icons.catching_pokemon;
        break;
      case PetType.bird:
        icon = Icons.flutter_dash;
        break;
      case PetType.fish:
        icon = Icons.water;
        break;
      case PetType.reptile:
        icon = Icons.pest_control;
        break;
      case PetType.hamster:
        icon = Icons.pets;
      case PetType.other:
        icon = Icons.pets;
        break;
    }

    return Icon(
      icon,
      size: 40,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 