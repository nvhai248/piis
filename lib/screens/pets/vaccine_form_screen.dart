import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/vaccine_history.dart';
import '../../services/vaccine_service.dart';
import '../../utils/message_utils.dart';

class VaccineFormScreen extends StatefulWidget {
  final String petId;
  final VaccineHistory? vaccineHistory;

  const VaccineFormScreen({
    Key? key,
    required this.petId,
    this.vaccineHistory,
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
    if (widget.vaccineHistory != null) {
      _nameController.text = widget.vaccineHistory!.name;
      _brandController.text = widget.vaccineHistory!.brand as String;
      _descriptionController.text = widget.vaccineHistory!.description as String;
      _quantityController.text = widget.vaccineHistory!.quantity.toString();
      _priceController.text = widget.vaccineHistory!.price.toString();
      _placeController.text = widget.vaccineHistory!.place as String;
      _reminderTimeController.text = widget.vaccineHistory!.reminderTime?.toString() ?? '';
      _dateOfVaccine = widget.vaccineHistory!.dateOfVaccine;
      _selectedType = widget.vaccineHistory!.type;
      _selectedRecordedBy = widget.vaccineHistory!.recordedBy;
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
        id: widget.vaccineHistory?.id as String,
        name: _nameController.text,
        dateOfVaccine: _dateOfVaccine,
        brand: _brandController.text,
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        price: int.parse(_priceController.text),
        place: _placeController.text,
        petId: widget.petId,
        type: _selectedType,
        recordedBy: _selectedRecordedBy,
        reminderTime: _reminderTimeController.text.isNotEmpty
            ? int.parse(_reminderTimeController.text)
            : null,
        createdAt: widget.vaccineHistory?.createdAt ?? now,
        updatedAt: now,
        status: widget.vaccineHistory?.status ?? VaccineStatus.upcomming,
      );

      final VaccineHistory updatedVaccine = widget.vaccineHistory != null
          ? await _vaccineService.updateVaccineHistory(vaccine)
          : await _vaccineService.createVaccineHistory(vaccine);

      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: widget.vaccineHistory != null
              ? 'Vaccine history updated successfully'
              : 'Vaccine history created successfully',
          type: MessageType.success,
        );
        Navigator.pop(context, updatedVaccine);
      }
    } catch (error) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to ${widget.vaccineHistory != null ? 'update' : 'create'} vaccine history',
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
        title: Text(widget.vaccineHistory != null ? 'Edit Vaccine' : 'Add Vaccine'),
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
                decoration: const InputDecoration(
                  labelText: 'Vaccine Name',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vaccine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Vaccine
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${_dateOfVaccine.year}-${_dateOfVaccine.month}-${_dateOfVaccine.day}',
                ),
                subtitle: const Text('Date of Vaccine'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter brand';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(
                  labelText: 'Place',
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter place';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<VaccineType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Vaccine Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: VaccineType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
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
                decoration: const InputDecoration(
                  labelText: 'Recorded By',
                  prefixIcon: Icon(Icons.person),
                ),
                items: RecordedBy.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
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
                decoration: const InputDecoration(
                  labelText: 'Reminder Time (days)',
                  prefixIcon: Icon(Icons.alarm),
                  hintText: 'Optional',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number of days';
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.vaccineHistory != null ? 'Update Vaccine' : 'Add Vaccine',
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