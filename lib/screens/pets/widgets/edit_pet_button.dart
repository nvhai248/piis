import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/pet.dart';
import '../pet_form_screen.dart';
import '../../../utils/message_utils.dart';

class EditPetButton extends StatelessWidget {
  final Pet pet;
  final VoidCallback onPetUpdated;

  const EditPetButton({
    super.key,
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