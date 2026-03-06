import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/merchant/data/mock_merchant_data.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class MerchantState extends Equatable {
  const MerchantState();

  @override
  List<Object?> get props => [];
}

class MerchantInitial extends MerchantState {
  const MerchantInitial();
}

class MerchantLoading extends MerchantState {
  const MerchantLoading();
}

class MerchantLoaded extends MerchantState {
  final MerchantProfile profile;
  final List<MerchantListing> activeListings;
  final List<MerchantListing> soldOutListings;
  final List<MerchantListing> expiredListings;
  final List<MerchantListing> draftListings;
  final List<MerchantOrder> pendingOrders;
  final List<MerchantOrder> completedOrders;
  final List<ActivityItem> activityFeed;

  const MerchantLoaded({
    required this.profile,
    required this.activeListings,
    required this.soldOutListings,
    required this.expiredListings,
    required this.draftListings,
    required this.pendingOrders,
    required this.completedOrders,
    required this.activityFeed,
  });

  int get pendingOrderCount => pendingOrders.length;

  MerchantLoaded copyWith({
    MerchantProfile? profile,
    List<MerchantListing>? activeListings,
    List<MerchantListing>? soldOutListings,
    List<MerchantListing>? expiredListings,
    List<MerchantListing>? draftListings,
    List<MerchantOrder>? pendingOrders,
    List<MerchantOrder>? completedOrders,
    List<ActivityItem>? activityFeed,
  }) {
    return MerchantLoaded(
      profile: profile ?? this.profile,
      activeListings: activeListings ?? this.activeListings,
      soldOutListings: soldOutListings ?? this.soldOutListings,
      expiredListings: expiredListings ?? this.expiredListings,
      draftListings: draftListings ?? this.draftListings,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      activityFeed: activityFeed ?? this.activityFeed,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        activeListings,
        soldOutListings,
        expiredListings,
        draftListings,
        pendingOrders,
        completedOrders,
        activityFeed,
      ];
}

class MerchantError extends MerchantState {
  final String message;
  const MerchantError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class MerchantCubit extends Cubit<MerchantState> {
  MerchantCubit() : super(const MerchantInitial());

  Future<void> load() async {
    emit(const MerchantLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(MerchantLoaded(
      profile: mockMerchantProfile,
      activeListings: List.from(mockActiveListings),
      soldOutListings: List.from(mockSoldOutListings),
      expiredListings: List.from(mockExpiredListings),
      draftListings: List.from(mockDraftListings),
      pendingOrders: List.from(mockPendingOrders),
      completedOrders: List.from(mockCompletedOrders),
      activityFeed: List.from(mockActivityFeed),
    ));
  }

  void pauseListing(String listingId) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    final updated = s.activeListings.map((l) {
      if (l.id == listingId) return l.copyWith(status: ListingStatus.paused);
      return l;
    }).toList();
    emit(s.copyWith(activeListings: updated));
  }

  void deleteListing(String listingId) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    emit(s.copyWith(
      activeListings: s.activeListings.where((l) => l.id != listingId).toList(),
      soldOutListings:
          s.soldOutListings.where((l) => l.id != listingId).toList(),
      expiredListings:
          s.expiredListings.where((l) => l.id != listingId).toList(),
      draftListings: s.draftListings.where((l) => l.id != listingId).toList(),
    ));
  }

  void markAsDonation(String listingId) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    final updated = s.activeListings.map((l) {
      if (l.id == listingId) return l.copyWith(status: ListingStatus.soldOut);
      return l;
    }).toList();
    final moved = s.activeListings.firstWhere((l) => l.id == listingId,
        orElse: () => s.activeListings.first);
    emit(s.copyWith(
      activeListings: updated.where((l) => l.id != listingId).toList(),
      soldOutListings: [...s.soldOutListings, moved.copyWith(status: ListingStatus.soldOut)],
    ));
  }

  void completedOrder(String orderId) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    final order = s.pendingOrders.firstWhere((o) => o.id == orderId,
        orElse: () => s.pendingOrders.first);
    final completed = order.copyWith(status: OrderStatus.completed);
    emit(s.copyWith(
      pendingOrders: s.pendingOrders.where((o) => o.id != orderId).toList(),
      completedOrders: [completed, ...s.completedOrders],
    ));
  }

  void addListing(MerchantListing listing) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    if (listing.status == ListingStatus.active) {
      emit(s.copyWith(activeListings: [listing, ...s.activeListings]));
    } else if (listing.status == ListingStatus.draft) {
      emit(s.copyWith(draftListings: [listing, ...s.draftListings]));
    }
  }

  void updateListingQuantity(String listingId, int newQuantity) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    final updated = s.activeListings.map((l) {
      if (l.id == listingId) return l.copyWith(totalQuantity: newQuantity);
      return l;
    }).toList();
    emit(s.copyWith(activeListings: updated));
  }

  void updateProfile(MerchantProfile updatedProfile) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    emit(s.copyWith(profile: updatedProfile));
  }
}
