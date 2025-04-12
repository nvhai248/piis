import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/pet.dart';
import '../../services/pet_service.dart';
import '../../utils/message_utils.dart';

class PetFormScreen extends StatefulWidget {
  final Pet? pet;

  const PetFormScreen({
    Key? key,
    this.pet,
  }) : super(key: key);

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petService = PetService(supabase: Supabase.instance.client);
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _classifyController = TextEditingController();
  final _anotherTypeController = TextEditingController();

  File? _imageFile;
  PetType _selectedType = PetType.dog;
  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _colorController.text = widget.pet!.color ?? '';
      _weightController.text = widget.pet!.weight?.toString() ?? '';
      _heightController.text = widget.pet!.height?.toString() ?? '';
      _classifyController.text = widget.pet!.petClassify ?? '';
      _anotherTypeController.text = widget.pet!.anotherPetType ?? '';
      _selectedType = widget.pet!.petType;
      if (widget.pet!.birthdayYear != null) {
        _birthDate = DateTime(
          widget.pet!.birthdayYear!,
          widget.pet!.birthdayMonth ?? 1,
          widget.pet!.birthdayDay ?? 1,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _classifyController.dispose();
    _anotherTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (error) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to pick image. Please try again.',
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _petService.uploadPetImage(_imageFile!.path);
      }

      final petData = {
        'name': _nameController.text.trim(),
        'pet_type': _selectedType,
        if (imageUrl != null) 'main_picture': imageUrl,
        if (_colorController.text.isNotEmpty) 'color': _colorController.text.trim(),
        if (_birthDate != null) ...{
          'birthday_year': _birthDate!.year,
          'birthday_month': _birthDate!.month,
          'birthday_day': _birthDate!.day,
        },
        if (_weightController.text.isNotEmpty)
          'weight': int.parse(_weightController.text),
        if (_heightController.text.isNotEmpty)
          'height': int.parse(_heightController.text),
        if (_classifyController.text.isNotEmpty)
          'pet_classify': _classifyController.text.trim(),
        if (_selectedType == PetType.other && _anotherTypeController.text.isNotEmpty)
          'another_pet_type': _anotherTypeController.text.trim(),
      };

      final Pet updatedPet = widget.pet != null
          ? await _petService.updatePet(
              id: widget.pet!.id,
              name: petData['name'] as String,
              petType: petData['pet_type'] as PetType,
              mainPicture: petData['main_picture'] as String?,
              color: petData['color'] as String?,
              birthdayYear: petData['birthday_year'] as int?,
              birthdayMonth: petData['birthday_month'] as int?,
              birthdayDay: petData['birthday_day'] as int?,
              weight: petData['weight'] as int?,
              height: petData['height'] as int?,
              petClassify: petData['pet_classify'] as String?,
              anotherPetType: petData['another_pet_type'] as String?,
            )
          : await _petService.createPet(
              name: petData['name'] as String,
              petType: petData['pet_type'] as PetType,
              mainPicture: petData['main_picture'] as String?,
              color: petData['color'] as String?,
              birthdayYear: petData['birthday_year'] as int?,
              birthdayMonth: petData['birthday_month'] as int?,
              birthdayDay: petData['birthday_day'] as int?,
              weight: petData['weight'] as int?,
              height: petData['height'] as int?,
              petClassify: petData['pet_classify'] as String?,
              anotherPetType: petData['another_pet_type'] as String?,
            );

      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: widget.pet != null
              ? 'Pet updated successfully'
              : 'Pet created successfully',
          type: MessageType.success,
        );
        Navigator.pop(context, updatedPet);
      }
    } catch (error) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to ${widget.pet != null ? 'update' : 'create'} pet. Please try again.',
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
        title: Text(widget.pet != null ? l10n.editPet : l10n.addPet),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Image
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              )
                            : widget.pet?.mainPicture != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.pet!.mainPicture!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: _imageFile == null && widget.pet?.mainPicture == null
                          ? Icon(
                              Icons.pets,
                              size: 48,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 18,
                          ),
                          color: theme.colorScheme.onPrimary,
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pet Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.petName,
                  prefixIcon: const Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.petNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pet Type
              DropdownButtonFormField<PetType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.petType,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: PetType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (PetType? value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Other Pet Type (if selected)
              if (_selectedType == PetType.other)
                TextFormField(
                  controller: _anotherTypeController,
                  decoration: InputDecoration(
                    labelText: l10n.otherPetType,
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (_selectedType == PetType.other &&
                        (value == null || value.trim().isEmpty)) {
                      return l10n.otherPetTypeRequired;
                    }
                    return null;
                  },
                ),
              if (_selectedType == PetType.other)
                const SizedBox(height: 16),

              // Birth Date
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(_birthDate != null
                    ? '${_birthDate!.year}-${_birthDate!.month}-${_birthDate!.day}'
                    : l10n.birthDate),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectBirthDate,
              ),
              const SizedBox(height: 16),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: l10n.color,
                  prefixIcon: const Icon(Icons.color_lens),
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: l10n.weight,
                  prefixIcon: const Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Height
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: l10n.height,
                  prefixIcon: const Icon(Icons.height),
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Breed/Classification
              TextFormField(
                controller: _classifyController,
                decoration: InputDecoration(
                  labelText: l10n.breed,
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
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
                      : Text(widget.pet != null ? l10n.update : l10n.create),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 