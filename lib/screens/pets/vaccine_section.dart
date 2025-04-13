import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/vaccine_history.dart';
import '../../utils/date_formatter.dart';

class VaccineHistoryItem extends StatelessWidget {
  final VaccineHistory vaccine;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const VaccineHistoryItem({
    super.key,
    required this.vaccine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        title: Text(vaccine.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.vaccineDate}: ${DateFormatter.formatDate(vaccine.dateOfVaccine)}'),
            if (vaccine.description != null && vaccine.description!.isNotEmpty)
              Text('${l10n.vaccineDescription}: ${vaccine.description}'),
            if (vaccine.brand != null && vaccine.brand!.isNotEmpty)
              Text('${l10n.brand}: ${vaccine.brand}'),
            if (vaccine.place != null && vaccine.place!.isNotEmpty)
              Text('${l10n.place}: ${vaccine.place}'),
            if (vaccine.price != null)
              Text('${l10n.price}: ${vaccine.price}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: l10n.editVaccineHistory,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.deleteVaccineHistory),
                    content: Text(l10n.deleteVaccineHistoryConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  await onDelete();
                }
              },
              tooltip: l10n.deleteVaccineHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyVaccineHistory extends StatelessWidget {
  const EmptyVaccineHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.vaccines_outlined,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noVaccineHistory,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}