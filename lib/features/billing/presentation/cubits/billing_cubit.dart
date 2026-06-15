import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/billing/data/repositories/billing_repository.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';

// ── States ──────────────────────────────────────────────────────────────────

abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {
  const BillingInitial();
}

class BillingLoading extends BillingState {
  const BillingLoading();
}

class BillingLoaded extends BillingState {
  final MerchantSubscription subscription;
  final List<SubscriptionPlan> plans;
  final List<SubscriptionPayment> payments;
  final List<CommissionLedger> commissions;
  final List<SponsoredSlot> sponsoredSlots;
  final List<SponsoredListing> sponsoredListings;

  const BillingLoaded({
    required this.subscription,
    required this.plans,
    required this.payments,
    required this.commissions,
    required this.sponsoredSlots,
    required this.sponsoredListings,
  });

  BillingLoaded copyWith({
    MerchantSubscription? subscription,
    List<SubscriptionPlan>? plans,
    List<SubscriptionPayment>? payments,
    List<CommissionLedger>? commissions,
    List<SponsoredSlot>? sponsoredSlots,
    List<SponsoredListing>? sponsoredListings,
  }) {
    return BillingLoaded(
      subscription: subscription ?? this.subscription,
      plans: plans ?? this.plans,
      payments: payments ?? this.payments,
      commissions: commissions ?? this.commissions,
      sponsoredSlots: sponsoredSlots ?? this.sponsoredSlots,
      sponsoredListings: sponsoredListings ?? this.sponsoredListings,
    );
  }

  @override
  List<Object?> get props => [
        subscription,
        plans,
        payments,
        commissions,
        sponsoredSlots,
        sponsoredListings,
      ];
}

class BillingError extends BillingState {
  final String message;
  const BillingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────────────────────

class BillingCubit extends Cubit<BillingState> {
  final BillingRepository _repository;

  BillingCubit({BillingRepository? repository})
      : _repository = repository ?? BillingRepository(),
        super(const BillingInitial());

  /// Load all billing related data for the authenticated merchant.
  Future<void> load() async {
    emit(const BillingLoading());
    try {
      final results = await Future.wait([
        _repository.fetchMySubscription(),
        _repository.fetchPlans(),
        _repository.fetchMyPayments(),
        _repository.fetchMyCommissions(),
        _repository.fetchMySponsoredSlots(),
        _repository.fetchMySponsoredListings(),
      ]);

      emit(BillingLoaded(
        subscription: results[0] as MerchantSubscription,
        plans: results[1] as List<SubscriptionPlan>,
        payments: results[2] as List<SubscriptionPayment>,
        commissions: results[3] as List<CommissionLedger>,
        sponsoredSlots: results[4] as List<SponsoredSlot>,
        sponsoredListings: results[5] as List<SponsoredListing>,
      ));
    } catch (e) {
      emit(BillingError(_friendlyError(e)));
    }
  }

  /// Request to upgrade/renew subscription.
  Future<void> requestUpgrade({
    required int planId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String paymentMethod,
    required String referenceNumber,
    String notes = '',
  }) async {
    if (state is! BillingLoaded) return;
    try {
      await _repository.createPaymentRequest(
        planId: planId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        notes: notes,
      );
      await load();
    } catch (e) {
      rethrow;
    }
  }

  /// Sponsor a listing.
  Future<void> sponsorListing({
    required String slotId,
    required String listingId,
  }) async {
    if (state is! BillingLoaded) return;
    try {
      await _repository.createSponsoredListing(
        slotId: slotId,
        listingId: listingId,
      );
      await load();
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel/Remove a sponsored listing.
  Future<void> removeSponsorship(String sponsoredListingId) async {
    if (state is! BillingLoaded) return;
    try {
      await _repository.cancelSponsoredListing(sponsoredListingId);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    if (msg.contains('403') || msg.contains('forbidden')) {
      return 'You do not have permission to view billing details.';
    }
    return 'Failed to load billing information: $msg';
  }
}
