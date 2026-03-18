import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/core/utils/app_logger.dart';
import 'package:anti_food_waste_app/features/merchant/data/repositories/merchant_repository.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';

// â”€â”€ States â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
  final List<Map<String, dynamic>> categories;

  const MerchantLoaded({
    required this.profile,
    required this.activeListings,
    required this.soldOutListings,
    required this.expiredListings,
    required this.draftListings,
    required this.pendingOrders,
    required this.completedOrders,
    required this.activityFeed,
    this.categories = const [],
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
    List<Map<String, dynamic>>? categories,
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
      categories: categories ?? this.categories,
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
        categories,
      ];
}

class MerchantError extends MerchantState {
  final String message;
  const MerchantError(this.message);

  @override
  List<Object?> get props => [message];
}

// â”€â”€ Cubit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class MerchantCubit extends Cubit<MerchantState> {
  final MerchantRepository _repository;

  MerchantCubit({MerchantRepository? repository})
      : _repository = repository ?? MerchantRepository(),
        super(const MerchantInitial());

  // â”€â”€ Dashboard load â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> load() async {
    emit(const MerchantLoading());
    try {
      final data = await _repository.loadDashboard();
      emit(_buildLoadedState(data.profile, data.listings, data.orders,
          data.categories));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.load', e, st);
      emit(MerchantError(_friendlyError(e)));
    }
  }

  // â”€â”€ Listing operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Creates a listing via the API.
  ///
  /// [form] holds all form values from the create-listing screen.
  /// [categoryId] must be the backend Category PK; use
  /// [_repository.resolveCategoryId] to look it up.
  Future<void> createListingAsync({
    required MerchantFoodCategory category,
    required String title,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required int quantity,
    required FreshnessGrade grade,
    required List<DietaryTag> dietaryTags,
    required DateTime pickupStart,
    required DateTime pickupEnd,
    String? imagePath,
  }) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;

    final categoryId =
        _repository.resolveCategoryId(category, s.categories);

    final payload = {
      'category': categoryId,
      'title': title,
      'description': description,
      'original_price': originalPrice.toStringAsFixed(2),
      'discounted_price': discountedPrice.toStringAsFixed(2),
      'quantity_total': quantity,
      'freshness_grade': grade.name.toUpperCase(),
      'pickup_start': pickupStart.toIso8601String(),
      'pickup_end': pickupEnd.toIso8601String(),
      'dietary_flags': MerchantListing.buildDietaryFlags(dietaryTags),
      'allergens': <String>[],
      'is_donation': false,
    };

    try {
      var listing = await _repository.createListing(payload);
      if (imagePath != null && imagePath.isNotEmpty && listing.id.isNotEmpty) {
        try {
          final photoUrl = await _repository.uploadListingPhoto(listing.id, imagePath);
          if (photoUrl.isNotEmpty) {
            listing = listing.copyWith(imageUrl: photoUrl);
          }
        } catch (_) {
          // Photo upload is best-effort; don't fail the whole create.
        }
      }
      if (listing.status == ListingStatus.active) {
        emit(s.copyWith(activeListings: [listing, ...s.activeListings]));
      } else {
        emit(s.copyWith(draftListings: [listing, ...s.draftListings]));
      }
    } catch (e, st) {
      AppLogger.error('MerchantCubit.createListingAsync', e, st);
      rethrow; // Let the UI surface the error.
    }
  }

  /// Optimistic local add (used after a successful API call or for drafts).
  void addListing(MerchantListing listing) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    if (listing.status == ListingStatus.active) {
      emit(s.copyWith(activeListings: [listing, ...s.activeListings]));
    } else if (listing.status == ListingStatus.draft) {
      emit(s.copyWith(draftListings: [listing, ...s.draftListings]));
    }
  }

  void pauseListing(String listingId) {
    // "Paused" is a UI-only concept; no backend call needed until the server
    // supports it.  Use sold_out semantics on next server sync.
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    final updated = s.activeListings.map((l) {
      if (l.id == listingId) return l.copyWith(status: ListingStatus.paused);
      return l;
    }).toList();
    emit(s.copyWith(activeListings: updated));
  }

  Future<void> deleteListingAsync(String listingId) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    // Optimistic removal.
    emit(s.copyWith(
      activeListings:
          s.activeListings.where((l) => l.id != listingId).toList(),
      soldOutListings:
          s.soldOutListings.where((l) => l.id != listingId).toList(),
      expiredListings:
          s.expiredListings.where((l) => l.id != listingId).toList(),
      draftListings:
          s.draftListings.where((l) => l.id != listingId).toList(),
    ));
    try {
      await _repository.deleteListing(listingId);
    } catch (e, st) {
      AppLogger.error('MerchantCubit.deleteListingAsync', e, st);
      // Reload to restore accurate state.
      await load();
      rethrow;
    }
  }

  /// Kept for backwards compatibility with screens that call the old sync API.
  void deleteListing(String listingId) {
    deleteListingAsync(listingId);
  }

  Future<void> markAsDonationAsync(String listingId) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      final updated = await _repository.markAsDonation(listingId);
      emit(s.copyWith(
        activeListings:
            s.activeListings.where((l) => l.id != listingId).toList(),
        soldOutListings: [...s.soldOutListings, updated],
      ));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.markAsDonationAsync', e, st);
      rethrow;
    }
  }

  /// Kept for backwards compatibility.
  void markAsDonation(String listingId) => markAsDonationAsync(listingId);

  void updateListingQuantity(String listingId, int newQuantity) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    final updated = s.activeListings.map((l) {
      if (l.id == listingId) return l.copyWith(totalQuantity: newQuantity);
      return l;
    }).toList();
    emit(s.copyWith(activeListings: updated));
  }

  // â”€â”€ Order operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Confirms an order by validating the consumer's QR code hash.
  Future<void> fulfillOrderAsync(String orderId, String qrHash) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      final fulfilled = await _repository.fulfillOrder(orderId, qrHash);
      emit(s.copyWith(
        pendingOrders:
            s.pendingOrders.where((o) => o.id != orderId).toList(),
        completedOrders: [fulfilled, ...s.completedOrders],
      ));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.fulfillOrderAsync', e, st);
      rethrow;
    }
  }

  /// Cancels a pending order as merchant.
  Future<void> cancelOrderAsync(String orderId, {String reason = ''}) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      final cancelled = await _repository.cancelOrder(orderId, reason: reason);
      emit(s.copyWith(
        pendingOrders: s.pendingOrders.where((o) => o.id != orderId).toList(),
        completedOrders: [cancelled, ...s.completedOrders],
      ));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.cancelOrderAsync', e, st);
      rethrow;
    }
  }

  /// Marks a pending order as no-show.
  Future<void> markNoShowAsync(String orderId) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      final updated = await _repository.markNoShow(orderId);
      emit(s.copyWith(
        pendingOrders: s.pendingOrders.where((o) => o.id != orderId).toList(),
        completedOrders: [updated, ...s.completedOrders],
      ));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.markNoShowAsync', e, st);
      rethrow;
    }
  }

  /// Fulfils an order by entering the consumer's 6-character pickup code
  /// (manual fallback when camera QR is unavailable).
  Future<void> fulfillByPickupCodeAsync(String pickupCode) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      final fulfilled = await _repository.fulfillByPickupCode(pickupCode);
      emit(s.copyWith(
        pendingOrders:
            s.pendingOrders.where((o) => o.id != fulfilled.id).toList(),
        completedOrders: [fulfilled, ...s.completedOrders],
      ));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.fulfillByPickupCodeAsync', e, st);
      rethrow;
    }
  }

  /// Optimistic local completion (backwards-compatible).
  void completedOrder(String orderId) {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    final order = s.pendingOrders.where((o) => o.id == orderId).firstOrNull;
    if (order == null) return;
    final completed = order.copyWith(status: OrderStatus.completed);
    emit(s.copyWith(
      pendingOrders:
          s.pendingOrders.where((o) => o.id != orderId).toList(),
      completedOrders: [completed, ...s.completedOrders],
    ));
  }

  // â”€â”€ Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void updateProfile(MerchantProfile updatedProfile) {
    if (state is! MerchantLoaded) return;
    emit((state as MerchantLoaded).copyWith(profile: updatedProfile));
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Splits a flat listing list into status buckets and builds [MerchantLoaded].
  static MerchantLoaded _buildLoadedState(
    MerchantProfile profile,
    List<MerchantListing> listings,
    List<MerchantOrder> orders,
    List<Map<String, dynamic>> categories,
  ) {
    final active =
        listings.where((l) => l.status == ListingStatus.active).toList();
    final soldOut =
        listings.where((l) => l.status == ListingStatus.soldOut).toList();
    final expired =
        listings.where((l) => l.status == ListingStatus.expired).toList();
    final drafts =
        listings.where((l) => l.status == ListingStatus.draft).toList();

    final pending =
        orders.where((o) => o.status == OrderStatus.pending).toList();
    final completed =
        orders.where((o) => o.status == OrderStatus.completed).toList();

    // Build activity feed from recent orders.
    final feed = orders.take(20).map((o) {
      return ActivityItem(
        type: o.status == OrderStatus.completed ? 'completed' : 'new_order',
        primaryText: o.listingTitle,
        secondaryText:
            '${o.quantity}x Â· ${o.totalAmount.toStringAsFixed(0)} DZD',
        timestamp: o.orderedAt,
        orderId: o.id,
      );
    }).toList();

    return MerchantLoaded(
      profile: profile,
      activeListings: active,
      soldOutListings: soldOut,
      expiredListings: expired,
      draftListings: drafts,
      pendingOrders: pending,
      completedOrders: completed,
      activityFeed: feed,
      categories: categories,
    );
  }

  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Could not reach the server. Check your network and the backend URL.';
    }
    if (msg.contains('401')) return 'Session expired. Please log in again.';
    if (msg.contains('403')) return 'Your account is not yet verified.';
    return 'Something went wrong. Please try again.';
  }
}
