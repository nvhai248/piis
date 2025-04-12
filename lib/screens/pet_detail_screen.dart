import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import '../utils/message_utils.dart';
import '../config/theme/app_theme.dart';
import 'pet_form_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({
    super.key,
    required this.petId,
  });

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final _petService = PetService(supabase: Supabase.instance.client);
  bool _isLoading = true;
  Pet? _pet;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    try {
      final pet = await _petService.getPet(widget.petId);
      if (mounted) {
        setState(() {
          _pet = pet;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to load pet details',
          type: MessageType.error,
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deletePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: const Text('Are you sure you want to delete this pet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'DELETE',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _petService.deletePet(widget.petId);
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Pet deleted successfully',
          type: MessageType.success,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to delete pet',
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> _editPet() async {
    if (_pet == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetFormScreen(pet: _pet),
      ),
    );

    _loadPet(); // Reload pet details after editing
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pet = _pet;
    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: const Center(child: Text('Pet not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPet,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pet.mainPicture != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(pet.mainPicture!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pet.displayType,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  if (pet.petClassify != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      pet.petClassify!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildInfoSection('Age', pet.ageDisplay),
                  if (pet.color != null)
                    _buildInfoSection('Color', pet.color!),
                  if (pet.weight != null)
                    _buildInfoSection(
                      'Weight',
                      '${pet.weight}g',
                    ),
                  if (pet.height != null)
                    _buildInfoSection(
                      'Height',
                      '${pet.height}cm',
                    ),
                  const SizedBox(height: 16),
                  if (pet.qrCodeUrl != null) ...[
                    const Text(
                      'QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Image.network(
                        pet.qrCodeUrl!,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
