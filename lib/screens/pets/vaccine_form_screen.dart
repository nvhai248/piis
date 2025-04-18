import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/vaccine_history.dart';
import '../../services/vaccine_service.dart';
import '../../utils/message_utils.dart';
import 'package:uuid/uuid.dart';

class VaccineFormScreen extends StatefulWidget {
  final String petId;
  final VaccineHistory? vaccineHistory;
  final Function(VaccineHistory)? onVaccineUpdated;

  const VaccineFormScreen({
    Key? key,
    required this.petId,
    this.vaccineHistory,
    this.onVaccineUpdated,
  }) : super(key: key);

  @override
  State<VaccineFormScreen> createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineService = VaccineService(Supabase.instance.client);
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _placeController = TextEditingController();
  final _reminderTimeController = TextEditingController();

  DateTime _dateOfVaccine = DateTime.now();
  VaccineType _selectedType = VaccineType.ONE_TIME;
  RecordedBy _selectedRecordedBy = RecordedBy.OWNER;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final history = widget.vaccineHistory;

    if (history != null) {
      _nameController.text = history.name;
      _brandController.text = history.brand ?? '';
      _descriptionController.text = history.description ?? '';
      _quantityController.text = history.quantity.toString();
      _priceController.text = history.price.toString();
      _placeController.text = history.place ?? '';
      _reminderTimeController.text = history.reminderTime?.toString() ?? '';
      _dateOfVaccine = history.dateOfVaccine;
      _selectedType = history.type;
      _selectedRecordedBy = history.recordedBy;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _placeController.dispose();
    _reminderTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context)!;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfVaccine,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() {
        _dateOfVaccine = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      final vaccine = VaccineHistory(
        id: widget.vaccineHistory?.id ?? const Uuid().v4(),
        name: _nameController.text,
        dateOfVaccine: _dateOfVaccine,
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        price: int.parse(_priceController.text),
        place: _placeController.text.isEmpty ? null : _placeController.text,
        petId: widget.petId,
        type: _selectedType,
        recordedBy: _selectedRecordedBy,
        reminderTime: _reminderTimeController.text.isNotEmpty
            ? int.parse(_reminderTimeController.text)
            : null,
        createdAt: widget.vaccineHistory?.createdAt ?? now,
        updatedAt: now,
        status: widget.vaccineHistory?.status ?? VaccineStatus.upcoming,
      );

      final VaccineHistory updatedVaccine = widget.vaccineHistory != null
          ? await _vaccineService.updateVaccineHistory(vaccine)
          : await _vaccineService.createVaccineHistory(vaccine);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        MessageUtils.showMessage(
          context,
          message: widget.vaccineHistory != null
              ? l10n.vaccineHistoryUpdateSuccess
              : l10n.vaccineHistoryCreateSuccess,
          type: MessageType.success,
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        MessageUtils.showMessage(
          context,
          message: widget.vaccineHistory != null
              ? l10n.vaccineHistoryUpdateError
              : l10n.vaccineHistoryCreateError,
          type: MessageType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vaccineHistory != null ? l10n.editVaccine : l10n.addVaccine,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.vaccineName,
                  prefixIcon: Icon(Icons.medical_services, color: theme.colorScheme.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterVaccineName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Vaccine
              ListTile(
                leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                title: Text(
                  '${_dateOfVaccine.year}-${_dateOfVaccine.month.toString().padLeft(2, '0')}-${_dateOfVaccine.day.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(l10n.dateOfVaccine, style: theme.textTheme.bodyMedium),
                trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                onTap: _selectDate,
                tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: l10n.brand,
                  prefixIcon: Icon(Icons.business, color: theme.colorScheme.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterBrand;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: Icon(Icons.description, color: theme.colorScheme.primary),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantity,
                  prefixIcon: Icon(Icons.numbers, color: theme.colorScheme.primary),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterQuantity;
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return l10n.pleaseEnterValidQuantity;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.price,
                  prefixIcon: Icon(Icons.attach_money, color: theme.colorScheme.primary),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterPrice;
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return l10n.pleaseEnterValidPrice;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _placeController,
                decoration: InputDecoration(
                  labelText: l10n.place,
                  prefixIcon: Icon(Icons.place, color: theme.colorScheme.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterPlace;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<VaccineType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.vaccineType,
                  prefixIcon: Icon(Icons.category, color: theme.colorScheme.primary),
                ),
                items: VaccineType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(l10n.vaccineTypeValue(type.name)),
                  );
                }).toList(),
                onChanged: (VaccineType? value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<RecordedBy>(
                value: _selectedRecordedBy,
                decoration: InputDecoration(
                  labelText: l10n.recordedBy,
                  prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                items: RecordedBy.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(l10n.recordedByValue(type.name)),
                  );
                }).toList(),
                onChanged: (RecordedBy? value) {
                  if (value != null) {
                    setState(() {
                      _selectedRecordedBy = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _reminderTimeController,
                decoration: InputDecoration(
                  labelText: l10n.reminderTimeDays,
                  prefixIcon: Icon(Icons.alarm, color: theme.colorScheme.primary),
                  hintText: l10n.optional,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return l10n.pleaseEnterValidDays;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          widget.vaccineHistory != null ? l10n.updateVaccine : l10n.addVaccine,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 