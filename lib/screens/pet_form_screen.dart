import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import '../utils/message_utils.dart';
import 'dart:io';

class PetFormScreen extends StatefulWidget {
  final Pet? pet;

  const PetFormScreen({super.key, this.pet});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petService = PetService(supabase: Supabase.instance.client);
  bool _isLoading = false;
  File? _imageFile;

  late TextEditingController _nameController;
  late PetType _selectedType;
  String? _anotherType;
  late TextEditingController _colorController;
  DateTime? _selectedBirthday;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _classifyController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name);
    _selectedType = pet?.petType ?? PetType.dog;
    _anotherType = pet?.anotherPetType;
    _colorController = TextEditingController(text: pet?.color);
    _selectedBirthday = pet?.birthday;
    _weightController = TextEditingController(
      text: pet?.weight?.toString(),
    );
    _heightController = TextEditingController(
      text: pet?.height?.toString(),
    );
    _classifyController = TextEditingController(
      text: pet?.petClassify,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _classifyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _petService.uploadPetImage(_imageFile!.path);
      }

      final birthday = _selectedBirthday;
      final pet = widget.pet;

      if (pet == null) {
        // Create new pet
        await _petService.createPet(
          name: _nameController.text,
          petType: _selectedType,
          mainPicture: imageUrl,
          color: _colorController.text.isNotEmpty ? _colorController.text : null,
          birthdayYear: birthday?.year,
          birthdayMonth: birthday?.month,
          birthdayDay: birthday?.day,
          weight: _weightController.text.isNotEmpty ? int.tryParse(_weightController.text) : null,
          height: _heightController.text.isNotEmpty ? int.tryParse(_heightController.text) : null,
          petClassify: _classifyController.text.isNotEmpty ? _classifyController.text : null,
          anotherPetType: _anotherType,
        );
      } else {
        // Update existing pet
        await _petService.updatePet(
          id: pet.id,
          name: _nameController.text,
          petType: _selectedType,
          mainPicture: imageUrl ?? pet.mainPicture,
          color: _colorController.text.isNotEmpty ? _colorController.text : null,
          birthdayYear: birthday?.year,
          birthdayMonth: birthday?.month,
          birthdayDay: birthday?.day,
          weight: _weightController.text.isNotEmpty ? int.tryParse(_weightController.text) : null,
          height: _heightController.text.isNotEmpty ? int.tryParse(_heightController.text) : null,
          petClassify: _classifyController.text.isNotEmpty ? _classifyController.text : null,
          anotherPetType: _anotherType,
        );
      }

      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: pet == null
              ? 'Pet added successfully!'
              : 'Pet updated successfully!',
          type: MessageType.success,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to save pet. Please try again.',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? 'Add Pet' : 'Edit Pet'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _savePet,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
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
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name*',
                  hintText: 'Enter your pet\'s name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PetType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Pet Type*',
                ),
                items: PetType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'Enter your pet\'s color',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Birthday'),
                subtitle: Text(
                  _selectedBirthday == null
                      ? 'Not set'
                      : '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedBirthday ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedBirthday = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (g)',
                        hintText: 'Enter weight in grams',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        hintText: 'Enter height in cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classifyController,
                decoration: const InputDecoration(
                  labelText: 'Pet Classification',
                  hintText: 'Enter breed or classification',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
