import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import 'pets/pet_form_screen.dart';
import 'pets/pet_details_screen.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({Key? key}) : super(key: key);

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final _petService = PetService(supabase: Supabase.instance.client);
  Stream<List<Pet>>? _petsStream;

  @override
  void initState() {
    super.initState();
    _initPetsStream();
  }

  void _initPetsStream() {
    setState(() {
      _petsStream = _petService.streamUserPets();
    });
  }

  Future<void> _navigateToPetForm({Pet? pet}) async {
    final result = await Navigator.push<Pet>(
      context,
      MaterialPageRoute(
        builder: (context) => PetFormScreen(pet: pet),
      ),
    );
    if (result != null) {
      _initPetsStream(); // Refresh the stream when returning from form
    }
  }

  Future<void> _navigateToPetDetails(Pet pet) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailsScreen(
          pet: pet,
          onPetUpdated: _initPetsStream,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.pets,
          semanticsLabel: l10n.pets,
        ),
      ),
      body: StreamBuilder<List<Pet>>(
        stream: _petsStream,
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
                    semanticLabel: l10n.errorLoadingPets,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingPets,
                    style: theme.textTheme.titleMedium,
                  ),
                  Tooltip(
                    message: l10n.addPet,
                    child: FilledButton.icon(
                      onPressed: () => _navigateToPetForm(),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addPet),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loading,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
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
                    semanticLabel: l10n.noPetsTitle,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noPetsTitle,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noPetsSubtitle,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Tooltip(
                    message: l10n.addPet,
                    child: FilledButton.icon(
                      onPressed: () => _navigateToPetForm(),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addPet),
                    ),
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
              return Semantics(
                button: true,
                label: '${pet.name}, ${pet.displayType}',
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => _navigateToPetDetails(pet),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'pet_image_${pet.id}',
                            child: Container(
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
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildChip(context, l10n.petType, pet.displayType),
                                    if (pet.petClassify != null)
                                      _buildChip(context, l10n.petBreed, pet.petClassify!),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _navigateToPetForm(pet: pet),
                            tooltip: l10n.editPet,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Semantics(
        button: true,
        label: l10n.addPet,
        child: FloatingActionButton(
          onPressed: () => _navigateToPetForm(),
          tooltip: l10n.addPet,
          child: const Icon(Icons.add),
        ),
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
        break;
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
    return Semantics(
      label: '$label: $value',
      child: Container(
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
      ),
    );
  }
} 