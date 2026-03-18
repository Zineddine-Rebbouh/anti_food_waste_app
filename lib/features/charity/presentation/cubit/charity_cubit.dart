import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/domain/repositories/charity_repository.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:anti_food_waste_app/features/charity/data/mock_charity_data.dart';
import 'package:anti_food_waste_app/core/utils/error_handler.dart';

class CharityCubit extends Cubit<CharityState> {
  final CharityRepository _repository;

  CharityCubit({required CharityRepository repository})
      : _repository = repository,
        super(CharityInitial());

  Future<void> fetchCharityData() async {
    emit(CharityLoading());
    try {
      final donations = await _repository.getDonations();
      final myRequests = await _repository.getMyPickupRequests();
      
      // Fallback temporarily to mocks if backend is completely empty while testing
      final displayDonations = donations.isNotEmpty ? donations : mockDonations;
      final displayRequests = myRequests.isNotEmpty ? myRequests : mockPickupRequests;
      
      emit(CharityLoaded(
        donations: displayDonations,
        myRequests: displayRequests,
      ));
    } catch (e) {
      final errorMessage = AppErrorHandler.getMessage(e);
      emit(CharityError(errorMessage));
    }
  }
}

