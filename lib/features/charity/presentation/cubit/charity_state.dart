import 'package:equatable/equatable.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';

abstract class CharityState extends Equatable {
  const CharityState();

  @override
  List<Object?> get props => [];
}

class CharityInitial extends CharityState {}

class CharityLoading extends CharityState {}

class CharityLoaded extends CharityState {
  final List<CharityDonation> donations;
  final List<CharityPickupRequest> myRequests;

  const CharityLoaded({
    required this.donations,
    required this.myRequests,
  });

  @override
  List<Object?> get props => [donations, myRequests];
}

class CharityError extends CharityState {
  final String message;

  const CharityError(this.message);

  @override
  List<Object?> get props => [message];
}
