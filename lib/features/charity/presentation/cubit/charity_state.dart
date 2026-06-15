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
  final List<CharityImpactReport> reports;

  const CharityLoaded({
    required this.donations,
    required this.myRequests,
    this.reports = const [],
  });

  @override
  List<Object?> get props => [donations, myRequests, reports];

  CharityLoaded copyWith({
    List<CharityDonation>? donations,
    List<CharityPickupRequest>? myRequests,
    List<CharityImpactReport>? reports,
  }) {
    return CharityLoaded(
      donations: donations ?? this.donations,
      myRequests: myRequests ?? this.myRequests,
      reports: reports ?? this.reports,
    );
  }
}

class CharityError extends CharityState {
  final String message;

  const CharityError(this.message);

  @override
  List<Object?> get props => [message];
}



