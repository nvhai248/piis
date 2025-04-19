import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/vaccine_history.dart';

class VaccineListItem extends StatelessWidget {
  final VaccineHistory vaccine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VaccineListItem({
    super.key,
    required this.vaccine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                vaccine.name,
                style: theme.textTheme.titleMedium,
              ),
            ),
            _buildStatusChip(context),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vaccine.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(
                vaccine.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.vaccineHistoryDate(
                    vaccine.dateOfVaccine.year,
                    vaccine.dateOfVaccine.month,
                    vaccine.dateOfVaccine.day,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (vaccine.brand != null || vaccine.place != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.business,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      [
                        if (vaccine.brand != null) vaccine.brand,
                        if (vaccine.place != null) vaccine.place,
                      ].where((e) => e != null).join(' - '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
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
              onPressed: () => _showDeleteConfirmation(context),
              tooltip: l10n.delete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Color chipColor;
    String statusText;
    IconData statusIcon;

    switch (vaccine.status) {
      case VaccineStatus.upcoming:
        chipColor = theme.colorScheme.primary;
        statusText = l10n.vaccineStatusUpcoming;
        statusIcon = Icons.upcoming;
        break;
      case VaccineStatus.completed:
        chipColor = theme.colorScheme.tertiary;
        statusText = l10n.vaccineStatusCompleted;
        statusIcon = Icons.check_circle;
        break;
      case VaccineStatus.overdue:
        chipColor = theme.colorScheme.error;
        statusText = l10n.vaccineStatusOverdue;
        statusIcon = Icons.warning;
        break;
    }

    return Chip(
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor),
      avatar: Icon(
        statusIcon,
        size: 16,
        color: chipColor,
      ),
      label: Text(
        statusText,
        style: theme.textTheme.bodySmall?.copyWith(color: chipColor),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDeleteConfirmationDialog(context, vaccine);
    if (confirmed) {
      onDelete();
    }
  }
}

Future<bool> showDeleteConfirmationDialog(BuildContext context, VaccineHistory vaccine) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        Icons.warning_rounded,
        color: theme.colorScheme.error,
        size: 32,
      ),
      title: Text(
        l10n.deleteVaccineHistory,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deleteVaccineHistoryConfirm,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Show vaccine details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.errorContainer,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (vaccine.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    vaccine.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.vaccineHistoryDate(
                        vaccine.dateOfVaccine.year,
                        vaccine.dateOfVaccine.month,
                        vaccine.dateOfVaccine.day,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (vaccine.brand != null || vaccine.place != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            if (vaccine.brand != null) vaccine.brand,
                            if (vaccine.place != null) vaccine.place,
                          ].where((e) => e != null).join(' - '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  ) ?? false;
} 