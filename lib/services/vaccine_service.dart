import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccine_history.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class VaccineService {
  final SupabaseClient _supabase;
  static const String _tableName = TableName.vaccineHistoryTable;

  VaccineService(this._supabase);

  Map<String, dynamic> _prepareDataForDb(VaccineHistory vaccine) {
    // Remove fields that are managed by the database
    final data = vaccine.toJson();
    data.remove('created_at');
    data.remove('updated_at');
    
    // Ensure all dates are in ISO8601 format
    if (data['date_of_vaccine'] != null) {
      data['date_of_vaccine'] = DateTime.parse(data['date_of_vaccine']).toIso8601String();
    }
    
    return data;
  }

  Future<List<VaccineHistory>> getPetVaccineHistories(String petId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('pet_id', petId)
          .order('date_of_vaccine', ascending: false);

      return response
          .map((row) => VaccineHistory.fromJson(row))
          .toList()
          .cast<VaccineHistory>();
    } catch (e) {
      debugPrint('Error getting vaccine histories: $e');
      rethrow;
    }
  }

  Stream<List<VaccineHistory>> streamPetVaccineHistories(String petId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('pet_id', petId)
        .map((maps) => maps
            .map((map) => VaccineHistory.fromJson(map))
            .toList());
  }

  Future<VaccineHistory> createVaccineHistory(VaccineHistory vaccine) async {
    final response = await _supabase
        .from(_tableName)
        .insert(vaccine.toJson())
        .select()
        .single();
    return VaccineHistory.fromJson(response);
  }

  Future<VaccineHistory> updateVaccineHistory(VaccineHistory vaccine) async {
    final response = await _supabase
        .from(_tableName)
        .update(vaccine.toJson())
        .eq('id', vaccine.id)
        .select()
        .single();
    return VaccineHistory.fromJson(response);
  }

  Future<void> deleteVaccineHistory(String id) async {
    await _supabase
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  Future<List<VaccineHistory>> getUpcomingVaccinations() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .gt('next_due_date', DateTime.now().toIso8601String())
          .order('next_due_date', ascending: true);

      return response
          .map((row) => VaccineHistory.fromJson(row))
          .toList()
          .cast<VaccineHistory>();
    } catch (e) {
      debugPrint('Error getting upcoming vaccinations: $e');
      rethrow;
    }
  }

  Stream<List<VaccineHistory>> streamUpcomingVaccinations() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .gt('next_due_date', DateTime.now().toIso8601String())
        .order('next_due_date', ascending: true)
        .map((rows) => rows
            .map((row) => VaccineHistory.fromJson(row))
            .toList());
  }

  Future<List<VaccineHistory>> getOverdueVaccinations() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .lt('next_due_date', DateTime.now().toIso8601String())
          .order('next_due_date', ascending: true);

      return response
          .map((row) => VaccineHistory.fromJson(row))
          .toList()
          .cast<VaccineHistory>();
    } catch (e) {
      debugPrint('Error getting overdue vaccinations: $e');
      rethrow;
    }
  }

  Stream<List<VaccineHistory>> streamOverdueVaccinations() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .lt('next_due_date', DateTime.now().toIso8601String())
        .order('next_due_date', ascending: true)
        .map((rows) => rows
            .map((row) => VaccineHistory.fromJson(row))
            .toList());
  }
} 