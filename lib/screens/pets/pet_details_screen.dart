import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/pet.dart';
import '../../models/vaccine_history.dart';
import '../../services/pet_service.dart';
import '../../services/vaccine_service.dart';
import '../pets/pet_form_screen.dart';
import '../pets/vaccine_form_screen.dart';
import '../../utils/message_utils.dart';
import 'vaccine_section.dart';

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;
  final VoidCallback onPetUpdated;

  const PetDetailsScreen({
    Key? key,
    required this.pet,
    required this.onPetUpdated,
  }) : super(key: key);

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late final VaccineService _vaccineService;

  @override
  void initState() {
    super.initState();
    _vaccineService = VaccineService(Supabase.instance.client);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return MultiProvider(
      providers: [
        Provider<PetService>(
          create: (context) => PetService(
            supabase: Supabase.instance.client,
          ),
        ),
        Provider<VaccineService>.value(
          value: _vaccineService,
        ),
        StreamProvider<List<VaccineHistory>>(
          create: (_) => _vaccineService.streamPetVaccineHistories(widget.pet.id),
          initialData: const [],
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.pet.name,
            semanticsLabel: '${l10n.petName}: ${widget.pet.name}',
          ),
          actions: [
            _EditPetButton(pet: widget.pet, onPetUpdated: widget.onPetUpdated),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PetImage(pet: widget.pet),
              const SizedBox(height: 24),
              _PetInformation(pet: widget.pet),
              const SizedBox(height: 16),
              _VaccineHistorySection(pet: widget.pet),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditPetButton extends StatelessWidget {
  final Pet pet;
  final VoidCallback onPetUpdated;

  const _EditPetButton({
    required this.pet,
    required this.onPetUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.editPet,
      child: IconButton(
        icon: const Icon(Icons.edit),
        tooltip: l10n.editPet,
        onPressed: () => _editPet(context),
      ),
    );
  }

  Future<void> _editPet(BuildContext context) async {
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
          message: AppLocalizations.of(context)!.petUpdatedSuccess,
          type: MessageType.success,
        );
      }
    }
  }
}

class _PetImage extends StatelessWidget {
  final Pet pet;

  const _PetImage({required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
                  )
                : _buildPlaceholder(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
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
    );
  }
}

class _PetInformation extends StatelessWidget {
  final Pet pet;

  const _PetInformation({required this.pet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoSection(
          title: l10n.petType,
          value: pet.petType == PetType.other
              ? pet.anotherPetType ?? l10n.otherPetType
              : pet.petType.name,
          icon: Icons.category,
        ),
        _InfoSection(
          title: l10n.birthDate,
          value: pet.birthdayYear != null
              ? '${pet.birthdayYear}-${pet.birthdayMonth}-${pet.birthdayDay}'
              : '-',
          icon: Icons.calendar_today,
        ),
        if (pet.color != null && pet.color!.isNotEmpty)
          _InfoSection(
            title: l10n.color,
            value: pet.color!,
            icon: Icons.color_lens,
          ),
        if (pet.weight != null)
          _InfoSection(
            title: l10n.weight,
            value: '${pet.weight} kg',
            icon: Icons.monitor_weight,
          ),
        if (pet.height != null)
          _InfoSection(
            title: l10n.height,
            value: '${pet.height} cm',
            icon: Icons.height,
          ),
        if (pet.petClassify != null && pet.petClassify!.isNotEmpty)
          _InfoSection(
            title: l10n.breed,
            value: pet.petClassify!,
            icon: Icons.pets,
          ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoSection({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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

class _VaccineHistorySection extends StatelessWidget {
  final Pet pet;

  const _VaccineHistorySection({required this.pet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.vaccineHistory,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addVaccine(context),
                  tooltip: l10n.addVaccineHistory,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _VaccineHistoryList(pet: pet),
          ],
        ),
      ),
    );
  }

  void _addVaccine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccineFormScreen(
          petId: pet.id,
        ),
      ),
    );
  }
}

class _VaccineHistoryList extends StatelessWidget {
  final Pet pet;

  const _VaccineHistoryList({required this.pet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vaccineHistory = context.watch<List<VaccineHistory>>();
    final vaccineService = context.read<VaccineService>();

    if (context.watch<List<VaccineHistory>>().isEmpty) {
      return const EmptyVaccineHistory();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vaccineHistory.length,
      itemBuilder: (context, index) {
        final vaccine = vaccineHistory[index];
        return VaccineHistoryItem(
          vaccine: vaccine,
          onEdit: () => _editVaccine(context, vaccine),
          onDelete: () => _deleteVaccine(context, vaccine.id),
        );
      },
    );
  }

  void _editVaccine(BuildContext context, VaccineHistory vaccine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccineFormScreen(
          petId: pet.id,
          vaccineHistory: vaccine,
        ),
      ),
    );
  }

  Future<void> _deleteVaccine(BuildContext context, String vaccineId) async {
    final l10n = AppLocalizations.of(context)!;
    final vaccineService = context.read<VaccineService>();

    try {
      await vaccineService.deleteVaccineHistory(vaccineId);
      if (context.mounted) {
        MessageUtils.showMessage(
          context,
          message: l10n.vaccineHistoryDeleteSuccess,
          type: MessageType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showMessage(
          context,
          message: l10n.vaccineHistoryDeleteError,
          type: MessageType.error,
        );
      }
    }
  }
}
