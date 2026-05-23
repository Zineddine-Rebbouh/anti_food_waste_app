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
  final List<MerchantListing> donationsListings;
  final List<MerchantOrder> pendingOrders;
  final List<MerchantOrder> activeOrders;
  final List<MerchantOrder> completedOrders;
  final List<ActivityItem> activityFeed;
  final List<Map<String, dynamic>> categories;

  const MerchantLoaded({
    required this.profile,
    required this.activeListings,
    required this.soldOutListings,
    required this.expiredListings,
    required this.draftListings,
    required this.donationsListings,
    required this.pendingOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.activityFeed,
    this.categories = const [],
  });

  int get pendingOrderCount => pendingOrders.length + activeOrders.length;

  MerchantLoaded copyWith({
    MerchantProfile? profile,
    List<MerchantListing>? activeListings,
    List<MerchantListing>? soldOutListings,
    List<MerchantListing>? expiredListings,
    List<MerchantListing>? draftListings,
    List<MerchantListing>? donationsListings,
    List<MerchantOrder>? pendingOrders,
    List<MerchantOrder>? activeOrders,
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
      donationsListings: donationsListings ?? this.donationsListings,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      activeOrders: activeOrders ?? this.activeOrders,
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
        donationsListings,
        pendingOrders,
        activeOrders,
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
      AppLogger.info('MerchantCubit: Creating listing with payload: $payload');
      var listing = await _repository.createListing(payload);
      AppLogger.info('MerchantCubit: Listing created successfully. ID: ${listing.id}');
      
      if (imagePath != null && imagePath.isNotEmpty && listing.id.isNotEmpty) {
        AppLogger.info('MerchantCubit: Attempting to upload photo for ${listing.id} from $imagePath');
        try {
          // The backend returns the photo object, extract the URL from it.
          final photoUrl = await _repository.uploadListingPhoto(listing.id, imagePath);
          AppLogger.info('MerchantCubit: Photo upload response URL: $photoUrl');
          if (photoUrl.isNotEmpty) {
            listing = listing.copyWith(imageUrl: photoUrl);
          }
        } catch (e) {
          AppLogger.error('MerchantCubit.createListingAsync: Photo upload failed', e);
          // Photo upload is best-effort; don't fail the whole create.
        }
      } else {
        AppLogger.info('MerchantCubit: Skipping photo upload. imagePath: $imagePath, listingId: ${listing.id}');
      }

      // Re-fetch the loaded state to ensure we have the latest list
      final currentLoaded = state as MerchantLoaded;
      AppLogger.info('MerchantCubit: Emitting updated state with listing ${listing.id}');
      if (listing.status == ListingStatus.active) {
        emit(currentLoaded.copyWith(activeListings: [listing, ...currentLoaded.activeListings]));
      } else {
        emit(currentLoaded.copyWith(draftListings: [listing, ...currentLoaded.draftListings]));
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

  Future<void> updateListingAsync(
    String listingId, {
    required String title,
    required String description,
    required double discountedPrice,
    required int quantity,
    required FreshnessGrade grade,
    required List<DietaryTag> dietaryTags,
    required DateTime pickupStart,
    required DateTime pickupEnd,
    String? imagePath,
  }) async {
    if (state is! MerchantLoaded) return;
    final payload = {
      'title': title,
      'description': description,
      'discounted_price': discountedPrice.toStringAsFixed(2),
      'quantity_available': quantity, // use available for updates usually
      'freshness_grade': grade.name.toUpperCase(),
      'pickup_start': pickupStart.toIso8601String(),
      'pickup_end': pickupEnd.toIso8601String(),
      'dietary_flags': MerchantListing.buildDietaryFlags(dietaryTags),
      'allergens': <String>[],
    };

    try {
      var listing = await _repository.updateListing(listingId, payload);
      
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          final photoUrl = await _repository.uploadListingPhoto(listingId, imagePath);
          if (photoUrl.isNotEmpty) {
            listing = listing.copyWith(imageUrl: photoUrl);
          }
        } catch (e) {
          AppLogger.error('MerchantCubit.updateListingAsync: Photo update failed', e);
        }
      }
      
      await load(); // Reload to refresh everything completely.
    } catch (e, st) {
      AppLogger.error('MerchantCubit.updateListingAsync', e, st);
      rethrow;
    }
  }

  Future<void> toggleListingStatusAsync(String listingId, ListingStatus newStatus) async {
    if (state is! MerchantLoaded) return;
    var statusStr = 'draft';
    if (newStatus == ListingStatus.active) {
      statusStr = 'active';
    } else if (newStatus == ListingStatus.soldOut) statusStr = 'sold_out';
    
    try {
      await _repository.updateListing(listingId, {'status': statusStr});
      await load();
    } catch (e, st) {
      AppLogger.error('MerchantCubit.toggleListingStatusAsync', e, st);
      rethrow;
    }
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
      donationsListings:
          s.donationsListings.where((l) => l.id != listingId).toList(),
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
        donationsListings: [updated, ...s.donationsListings],
      ));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.markAsDonationAsync', e, st);
      rethrow;
    }
  }

  /// Kept for backwards compatibility.
  void markAsDonation(String listingId) => markAsDonationAsync(listingId);

  Future<void> unmarkAsDonationAsync(String listingId) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      final updated = await _repository.unmarkAsDonation(listingId);
      emit(s.copyWith(
        donationsListings:
            s.donationsListings.where((l) => l.id != listingId).toList(),
        activeListings: [updated, ...s.activeListings],
      ));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.unmarkAsDonationAsync', e, st);
      rethrow;
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

  /// Confirms a donation pickup by validating the charity's QR code hash.
  Future<void> fulfillDonationAsync(String donationId, String qrHash) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      await _repository.fulfillDonation(donationId, qrHash);
      
      // Find the local order object to move it to completed
      final order = s.pendingOrders.where((o) => o.id == donationId).firstOrNull;
      if (order != null) {
        final fulfilled = order.copyWith(status: OrderStatus.completed);
        emit(s.copyWith(
          pendingOrders:
              s.pendingOrders.where((o) => o.id != donationId).toList(),
          completedOrders: [fulfilled, ...s.completedOrders],
        ));
      }
    } catch (e, st) {
      AppLogger.error('MerchantCubit.fulfillDonationAsync', e, st);
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

  Future<void> approveDonationRequestAsync(String donationId, String requestId) async {
    if (state is! MerchantLoaded) return;
    try {
      await _repository.approveDonationRequest(donationId, requestId);
      // Reload everything fully instead of maintaining state manually,
      // as it forces the status of this request and cancels any others.
      await load();
    } catch (e, st) {
      AppLogger.error('MerchantCubit.approveDonationRequestAsync', e, st);
      rethrow;
    }
  }

  // â”€â”€ Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void updateProfile(MerchantProfile updatedProfile) {
    if (state is! MerchantLoaded) return;
    emit((state as MerchantLoaded).copyWith(profile: updatedProfile));
  }

  Future<void> updateProfileAsync({
    required String businessName,
    required String businessType,
    required String phone,
    required String address,
    required String wilaya,
    String? avatarUrl,
    double? latitude,
    double? longitude,
  }) async {
    if (state is! MerchantLoaded) return;
    final s = state as MerchantLoaded;
    try {
      // 1. Update basic profile info
      var updated = await _repository.updateProfile({
        'profile': {
          'business_name': businessName,
          'business_type': businessType,
          'phone': phone,
          'address': address,
          'wilaya': wilaya,
        }
      });

      // 2. Update location if coordinates provided
      if (latitude != null && longitude != null) {
        try {
          await _repository.updateLocation(
            latitude: latitude,
            longitude: longitude,
            address: address,
            wilaya: wilaya,
          );
        } catch (e) {
          AppLogger.error('MerchantCubit.updateProfileAsync: Location update failed', e);
        }
      }

      // 3. Merge logo logic
      if (updated.avatarUrl.isEmpty) {
        final fallbackUrl = avatarUrl ?? s.profile.avatarUrl;
        if (fallbackUrl.isNotEmpty) {
          updated = updated.copyWith(avatarUrl: fallbackUrl);
        }
      } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updated = updated.copyWith(avatarUrl: avatarUrl);
      }
      
      emit(s.copyWith(profile: updated));
    } catch (e, st) {
      AppLogger.error('MerchantCubit.updateProfileAsync', e, st);
      rethrow;
    }
  }

  Future<String> uploadLogoAsync(String filePath) async {
    if (state is! MerchantLoaded) return '';
    final s = state as MerchantLoaded;
    try {
      final logoUrl = await _repository.uploadLogo(filePath);
      if (logoUrl.isNotEmpty) {
        final normalized = MerchantProfile.normalizeUrl(logoUrl);
        emit(s.copyWith(profile: s.profile.copyWith(avatarUrl: normalized)));
        return normalized;
      }
      return logoUrl;
    } catch (e, st) {
      AppLogger.error('MerchantCubit.uploadLogoAsync', e, st);
      rethrow;
    }
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
        listings.where((l) => l.status == ListingStatus.active && !l.isDonation).toList();
    final donations =
        listings.where((l) => l.status == ListingStatus.active && l.isDonation).toList();
    final soldOut =
        listings.where((l) => l.status == ListingStatus.soldOut).toList();
    final expired =
        listings.where((l) => l.status == ListingStatus.expired).toList();
    final drafts =
        listings.where((l) => l.status == ListingStatus.draft).toList();

    final pending =
        orders.where((o) => o.status == OrderStatus.pending).toList();
    final activeOrders =
        orders.where((o) => o.status == OrderStatus.active).toList();
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
      donationsListings: donations,
      pendingOrders: pending,
      activeOrders: activeOrders,
      completedOrders: completed,
      activityFeed: feed,
      categories: categories,
    );
  }

  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'error_no_connection';
    }
    if (msg.contains('401')) return 'error_unauthorized';
    if (msg.contains('403')) return 'error_forbidden';
    return 'error_generic';
  }
}



