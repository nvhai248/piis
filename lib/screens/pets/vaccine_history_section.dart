import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../models/vaccine_history.dart';
import '../../services/vaccine_service.dart';
import '../../utils/message_utils.dart';
import 'vaccine_form_screen.dart';
import 'widgets/vaccine_list_item.dart';

class VaccineHistorySection extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onRefreshRequested;

  const VaccineHistorySection({
    super.key,
    required this.pet,
    this.onRefreshRequested,
  });

  @override
  State<VaccineHistorySection> createState() => _VaccineHistorySectionState();
}

class _VaccineHistorySectionState extends State<VaccineHistorySection> {
  late final VaccineService _vaccineService;

  @override
  void initState() {
    super.initState();
    _vaccineService = context.read<VaccineService>();
  }

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
                Tooltip(
                  message: l10n.addVaccineHistory,
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addVaccine(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildVaccineList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Consumer<List<VaccineHistory>>(
      builder: (context, vaccineHistory, child) {
        // Handle empty state
        if (vaccineHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.vaccines_outlined,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noVaccineHistory,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _addVaccine(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addVaccineHistory),
                ),
              ],
            ),
          );
        }

        // Sort vaccines by date, most recent first
        final sortedVaccines = List<VaccineHistory>.from(vaccineHistory)
          ..sort((a, b) => b.dateOfVaccine.compareTo(a.dateOfVaccine));

        // Show vaccine list with animations
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ListView.builder(
            key: ValueKey(sortedVaccines.length),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedVaccines.length,
            itemBuilder: (context, index) {
              final vaccine = sortedVaccines[index];
              return _buildVaccineItem(context, vaccine, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildVaccineItem(BuildContext context, VaccineHistory vaccine, int index) {
    return AnimatedSlide(
      duration: Duration(milliseconds: 200 + (index * 50)),
      offset: const Offset(0, 0),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200 + (index * 50)),
        opacity: 1,
        child: Dismissible(
          key: Key(vaccine.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => showDeleteConfirmationDialog(context, vaccine),
          onDismissed: (direction) => _deleteVaccine(context, vaccine.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          child: VaccineListItem(
            vaccine: vaccine,
            onEdit: () => _editVaccine(context, vaccine),
            onDelete: () => _showDeleteConfirmation(context, vaccine),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, VaccineHistory vaccine) async {
    final confirmed = await showDeleteConfirmationDialog(context, vaccine);
    if (confirmed && context.mounted) {
      await _deleteVaccine(context, vaccine.id);
    }
  }

  void _addVaccine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccineFormScreen(
          petId: widget.pet.id,
          onVaccineUpdated: (_) {
            widget.onRefreshRequested?.call();
          },
        ),
      ),
    );
  }

  void _editVaccine(BuildContext context, VaccineHistory vaccine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccineFormScreen(
          petId: widget.pet.id,
          vaccineHistory: vaccine,
          onVaccineUpdated: (_) {
            widget.onRefreshRequested?.call();
          },
        ),
      ),
    );
  }

  Future<void> _deleteVaccine(BuildContext context, String vaccineId) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await _vaccineService.deleteVaccineHistory(vaccineId);
      
      if (context.mounted) {
        MessageUtils.showMessage(
          context,
          message: l10n.vaccineHistoryDeleteSuccess,
          type: MessageType.success,
        );
        widget.onRefreshRequested?.call();
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