import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccine_history.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class VaccineService {
  final SupabaseClient _client;

  VaccineService(this._client);

  Future<List<VaccineHistory>> getPetVaccineHistories(String petId) async {
    try {
      final response = await _client
          .from(TableName.vaccineHistoryTable)
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
    try {
      return _client
          .from(TableName.vaccineHistoryTable)
          .stream(primaryKey: ['id'])
          .eq('pet_id', petId)
          .order('date_of_vaccine', ascending: false)
          .handleError((error) {
            debugPrint('Error in vaccine history stream: $error');
            return [];
          })
          .map((rows) {
            try {
              return rows.map((row) {
                try {
                  return VaccineHistory.fromJson(row);
                } catch (e) {
                  debugPrint('Error parsing vaccine history: $e');
                  debugPrint('Problematic row: $row');
                  return null;
                }
              }).where((item) => item != null).cast<VaccineHistory>().toList();
            } catch (e) {
              debugPrint('Error mapping vaccine histories: $e');
              return [];
            }
          });
    } catch (e) {
      debugPrint('Error setting up vaccine history stream: $e');
      return Stream.value([]);
    }
  }

  Future<VaccineHistory> createVaccineHistory(VaccineHistory vaccine) async {
    try {
      final response = await _client
          .from(TableName.vaccineHistoryTable)
          .insert(vaccine.toJson())
          .select()
          .single();

      return VaccineHistory.fromJson(response);
    } catch (e) {
      debugPrint('Error creating vaccine history: $e');
      rethrow;
    }
  }

  Future<VaccineHistory> updateVaccineHistory(VaccineHistory vaccine) async {
    try {
      final response = await _client
          .from(TableName.vaccineHistoryTable)
          .update(vaccine.toJson())
          .eq('id', vaccine.id)
          .select()
          .single();

      return VaccineHistory.fromJson(response);
    } catch (e) {
      debugPrint('Error updating vaccine history: $e');
      rethrow;
    }
  }

  Future<void> deleteVaccineHistory(String id) async {
    try {
      await _client
          .from(TableName.vaccineHistoryTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error deleting vaccine history: $e');
      rethrow;
    }
  }

  Future<List<VaccineHistory>> getUpcomingVaccinations() async {
    try {
      final response = await _client
          .from(TableName.vaccineHistoryTable)
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
    return _client
        .from(TableName.vaccineHistoryTable)
        .stream(primaryKey: ['id'])
        .gt('next_due_date', DateTime.now().toIso8601String())
        .order('next_due_date', ascending: true)
        .map((rows) => rows
            .map((row) => VaccineHistory.fromJson(row))
            .toList());
  }

  Future<List<VaccineHistory>> getOverdueVaccinations() async {
    try {
      final response = await _client
          .from(TableName.vaccineHistoryTable)
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
    return _client
        .from(TableName.vaccineHistoryTable)
        .stream(primaryKey: ['id'])
        .lt('next_due_date', DateTime.now().toIso8601String())
        .order('next_due_date', ascending: true)
        .map((rows) => rows
            .map((row) => VaccineHistory.fromJson(row))
            .toList());
  }
} 