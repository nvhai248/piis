import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/pet.dart';
import '../../models/vaccine_history.dart';
import '../../services/pet_service.dart';
import '../../services/vaccine_service.dart';
import 'pet_details_section.dart';
import 'vaccine_history_section.dart';
import 'widgets/edit_pet_button.dart';

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
  StreamController<List<VaccineHistory>>? _vaccineStreamController;

  @override
  void initState() {
    super.initState();
    _vaccineService = VaccineService(Supabase.instance.client);
    _vaccineStreamController = StreamController<List<VaccineHistory>>();
    _loadVaccines();
  }

  Future<void> _loadVaccines() async {
    final vaccines = await _vaccineService.getPetVaccineHistories(widget.pet.id);
    _vaccineStreamController?.add(vaccines);
  }

  void _refreshVaccines() {
    _loadVaccines();
  }

  @override
  void dispose() {
    _vaccineStreamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_vaccineStreamController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiProvider(
      providers: [
        Provider<PetService>(
          create: (_) => PetService(supabase: Supabase.instance.client),
        ),
        Provider<VaccineService>.value(value: _vaccineService),
        StreamProvider<List<VaccineHistory>>.value(
          value: _vaccineStreamController!.stream,
          initialData: const [],
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.pet.name),
          actions: [
            EditPetButton(
              pet: widget.pet,
              onPetUpdated: widget.onPetUpdated,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PetDetailsSection(pet: widget.pet),
              const SizedBox(height: 16),
              VaccineHistorySection(
                pet: widget.pet,
                onRefreshRequested: _refreshVaccines,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
