import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';
import '../models/service.dart';
import '../models/plan.dart';
import '../models/pet_care.dart';

class PetService {
  final SupabaseClient supabase;

  PetService({required this.supabase});

  static const String _table = 'pets';

  // Get all pets for the current user
  Future<List<Pet>> getUserPets() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('status', PetStatus.ACTIVE.name)
          .order('created_at');

      return (response as List).map((pet) => Pet.fromJson(pet)).toList();
    } catch (error) {
      print('Error getting user pets: $error');
      rethrow;
    }
  }

  // Get a single pet by ID
  Future<Pet?> getPet(String id) async {
    try {
      final response = await supabase
          .from(_table)
          .select()
          .eq('id', id)
          .single();

      return response == null ? null : Pet.fromJson(response);
    } catch (error) {
      print('Error getting pet: $error');
      rethrow;
    }
  }

  // Create a new pet
  Future<Pet> createPet({
    required String name,
    required PetType petType,
    String? mainPicture,
    String? color,
    int? birthdayYear,
    int? birthdayMonth,
    int? birthdayDay,
    int? weight,
    int? height,
    String? petClassify,
    String? anotherPetType,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final petData = {
        'name': name,
        'pet_type': petType.name,
        'main_picture': mainPicture,
        'color': color,
        'birthday_year': birthdayYear,
        'birthday_month': birthdayMonth,
        'birthday_day': birthdayDay,
        'weight': weight,
        'height': height,
        'pet_classify': petClassify,
        'another_pet_type': anotherPetType,
        'user_id': userId,
        'status': PetStatus.ACTIVE.name,
      };

      final response = await supabase
          .from(_table)
          .insert(petData)
          .select()
          .single();

      return Pet.fromJson(response);
    } catch (error) {
      print('Error creating pet: $error');
      rethrow;
    }
  }

  // Update an existing pet
  Future<Pet> updatePet({
    required String id,
    String? name,
    PetType? petType,
    String? mainPicture,
    String? color,
    int? birthdayYear,
    int? birthdayMonth,
    int? birthdayDay,
    int? weight,
    int? height,
    String? petClassify,
    String? anotherPetType,
    PetStatus? status,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Build update data only with non-null values
      final updateData = {
        if (name != null) 'name': name,
        if (petType != null) 'pet_type': petType.name,
        if (mainPicture != null) 'main_picture': mainPicture,
        if (color != null) 'color': color,
        if (birthdayYear != null) 'birthday_year': birthdayYear,
        if (birthdayMonth != null) 'birthday_month': birthdayMonth,
        if (birthdayDay != null) 'birthday_day': birthdayDay,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (petClassify != null) 'pet_classify': petClassify,
        if (anotherPetType != null) 'another_pet_type': anotherPetType,
        if (status != null) 'status': status.name,
      };

      final response = await supabase
          .from(_table)
          .update(updateData)
          .eq('id', id)
          .eq('user_id', userId) // Ensure user owns the pet
          .select()
          .single();

      return Pet.fromJson(response);
    } catch (error) {
      print('Error updating pet: $error');
      rethrow;
    }
  }

  // Delete a pet (soft delete by setting status to pass away)
  Future<void> deletePet(String id) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await supabase
          .from(_table)
          .update({'status': PetStatus.PASS_AWAY.name})
          .eq('id', id)
          .eq('user_id', userId); // Ensure user owns the pet
    } catch (error) {
      print('Error deleting pet: $error');
      rethrow;
    }
  }

  // Upload a pet image to storage
  Future<String> uploadPetImage(String filePath) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileExt = filePath.split('.').last;
      final fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final file = File(filePath);
      
      // Upload the file
      final String path = '$userId/$fileName';
      await supabase.storage
          .from('pet-images')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false
            ),
          );

      // Get the public URL with the CDN URL
      final String publicUrl = supabase.storage
          .from('pet-images')
          .getPublicUrl(path);

      // Verify the image was uploaded successfully
      try {
        final response = await supabase.storage
            .from('pet-images')
            .download(path);
        if (response.isEmpty) {
          throw Exception('Failed to verify image upload');
        }
      } catch (e) {
        print('Error verifying image upload: $e');
        rethrow;
      }

      return publicUrl;
    } catch (error) {
      print('Error uploading pet image: $error');
      rethrow;
    }
  }

  // Stream of pets for real-time updates
  Stream<List<Pet>> streamUserPets() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .map((event) => event
            .where((pet) => 
                pet['user_id'] == userId && 
                pet['status'] == PetStatus.ACTIVE.name)
            .map((pet) => Pet.fromJson(pet))
            .toList());
  }

  // Stream of active pets for the current user
  Stream<List<Pet>> getActivePetsStream() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return supabase
        .from('pets')
        .stream(primaryKey: ['id'])
        .map((rows) => rows
            .where((pet) => 
                pet['user_id'] == userId && 
                pet['status'] == PetStatus.ACTIVE.name)
            .map((pet) => Pet.fromJson(pet))
            .toList());
  }

  // Stream of all services
  Stream<List<Service>> getServicesStream() {
    return supabase
        .from('services')
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((row) => Service.fromJson(row)).toList());
  }

  // Stream of active plans for the current user
  Stream<List<Plan>> getActivePlansStream() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return supabase
        .from('plans')
        .stream(primaryKey: ['id'])
        .map((rows) => rows
            .where((plan) => 
                plan['user_id'] == userId && 
                plan['status'] == PlanStatus.active.name)
            .map((plan) => Plan.fromJson(plan))
            .toList());
  }

  // Stream of nearby pet care facilities
  Stream<List<PetCare>> getNearbyPetCareStream() {
    return supabase
        .from('pet_care')
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((row) => PetCare.fromJson(row)).toList());
  }

  // Get all active pets for the current user
  Future<List<Pet>> getActivePets() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('pets')
        .select()
        .eq('user_id', userId)
        .eq('status', PetStatus.ACTIVE.name);
    return response.map((row) => Pet.fromJson(row)).toList();
  }

  // Get all services
  Future<List<Service>> getServices() async {
    final response = await supabase.from('services').select();
    return (response as List).map((row) => Service.fromJson(row)).toList();
  }

  // Get all active plans for the current user
  Future<List<Plan>> getActivePlans() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('plans')
        .select()
        .eq('user_id', userId)
        .eq('status', PlanStatus.active.name);
    return response.map((row) => Plan.fromJson(row)).toList();
  }

  // Get nearby pet care facilities
  Future<List<PetCare>> getNearbyPetCare() async {
    final response = await supabase.from('pet_care').select();
    return response.map((row) => PetCare.fromJson(row)).toList();
  }
}
