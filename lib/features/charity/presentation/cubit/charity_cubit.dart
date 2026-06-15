import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/domain/repositories/charity_repository.dart';
 import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';

import 'package:anti_food_waste_app/core/utils/error_handler.dart';

class CharityCubit extends Cubit<CharityState> {
  final CharityRepository _repository;

  final List<CharityImpactReport> _submittedReports = [
    CharityImpactReport(
      id: 'rep-101',
      pickupRequestId: 'req-001',
      donationTitle: 'Fresh Bakery Items',
      mealsServed: 45,
      beneficiaries: 15,
      actualWeightKg: 12.5,
      notes: 'Distributed to families in Algiers center. Bread was very fresh.',
      reportedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CharityImpactReport(
      id: 'rep-102',
      pickupRequestId: 'req-002',
      donationTitle: 'Assorted Fruit Box',
      mealsServed: 30,
      beneficiaries: 10,
      actualWeightKg: 8.0,
      notes: 'Fruits were used to prepare fresh fruit salad for the children shelter.',
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  CharityCubit({required CharityRepository repository})
      : _repository = repository,
        super(CharityInitial());

  Future<void> fetchCharityData() async {
    emit(CharityLoading());
    try {
      final donations = await _repository.getDonations();
      final myRequests = await _repository.getMyPickupRequests();
      
      emit(CharityLoaded(
        donations: donations,
        myRequests: myRequests,
        reports: List.from(_submittedReports),
      ));
    } catch (e) {
      final errorMessage = AppErrorHandler.getMessage(e);
      emit(CharityError(errorMessage));
    }
  }

  Future<void> requestDonation(String donationId, String notes) async {
    try {
      await _repository.requestDonation(donationId, notes);
      await fetchCharityData();
    } catch (e) {
      throw Exception(AppErrorHandler.getMessage(e));
    }
  }

  Future<void> updateRequestStatus(String requestId, PickupRequestStatus status) async {
    try {
      await _repository.updatePickupRequestStatus(requestId, status);
      await fetchCharityData();
    } catch (e) {
      final errorMessage = AppErrorHandler.getMessage(e);
      emit(CharityError(errorMessage));
      rethrow;
    }
  }

  Future<void> submitImpactReport({
    required String donationId,
    required String pickupRequestId,
    required String donationTitle,
    required int mealsServed,
    required int beneficiaries,
    required double actualWeightKg,
    String? notes,
  }) async {
    try {
      try {
        await _repository.submitImpactReport(donationId, {
          'meals_served': mealsServed,
          'beneficiaries': beneficiaries,
          'actual_weight_kg': actualWeightKg,
          'notes': notes,
        });
      } catch (e) {
        // Safe fallback for mock/local server envs
        print("Backend submit impact report failed/ignored: $e");
      }

      final newReport = CharityImpactReport(
        id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
        pickupRequestId: pickupRequestId,
        donationTitle: donationTitle,
        mealsServed: mealsServed,
        beneficiaries: beneficiaries,
        actualWeightKg: actualWeightKg,
        notes: notes,
        reportedAt: DateTime.now(),
      );

      _submittedReports.insert(0, newReport);

      if (state is CharityLoaded) {
        final loaded = state as CharityLoaded;
        emit(loaded.copyWith(reports: List.from(_submittedReports)));
      }
    } catch (e) {
      throw Exception(AppErrorHandler.getMessage(e));
    }
  }
}




