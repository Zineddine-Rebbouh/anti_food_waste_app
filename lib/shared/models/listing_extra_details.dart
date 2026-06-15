import 'package:anti_food_waste_app/core/config/app_config.dart';

class ListingReview {
  final String id;
  final String userName;
  final double rating;
  final String date;
  final String comment;
  final int helpfulCount;
  final String? merchantReply;

  ListingReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.date,
    required this.comment,
    required this.helpfulCount,
    this.merchantReply,
  });
}

class ListingFAQ {
  final String question;
  final String answer;

  ListingFAQ({
    required this.question,
    required this.answer,
  });
}

class MerchantDetails {
  final String id;
  final String name;
  final String? logoUrl;
  final String? coverImageUrl;
  final String address;
  final double lat;
  final double lng;
  final List<String> badges;
  final String? phone;
  final String? wilaya;
  final String bio;
  final int mealsSaved;
  final int fulfillmentRate;
  final String memberSince;
  final double averageRating;
  final int totalReviews;

  MerchantDetails({
    required this.id,
    required this.name,
    this.logoUrl,
    this.coverImageUrl,
    required this.address,
    this.phone,
    this.wilaya,
    required this.lat,
    required this.lng,
    required this.badges,
    required this.bio,
    required this.mealsSaved,
    required this.fulfillmentRate,
    required this.memberSince,
    required this.averageRating,
    required this.totalReviews,
  });
}

class ListingExtraDetails {
  final String id;
  final String description;
  final List<String> images;
  final String phone;
  final String address;
  final List<String> whatYouGet;
  final MerchantDetails merchant;
  final List<ListingReview> reviews;
  final List<ListingFAQ> faqs;
  final bool userHasReserved;

  ListingExtraDetails({
    required this.id,
    required this.description,
    required this.images,
    required this.phone,
    required this.address,
    required this.whatYouGet,
    required this.merchant,
    required this.reviews,
    required this.faqs,
    this.userHasReserved = false,
  });

  /// Builds a [ListingExtraDetails] from a backend [ListingDetailSerializer] response.
  factory ListingExtraDetails.fromDetailJson(Map<String, dynamic> json) {
    final merchantInfo = (json['merchant_info'] as Map<String, dynamic>?) ?? 
                         (json['merchant'] as Map<String, dynamic>?) ?? 
                         {};
    final userHasReserved = json['user_has_reserved'] as bool? ?? false;


    String normalizeUrl(String url) {
      if (url.isEmpty) return '';
      
      // Check for known broken Unsplash URLs from mock data or backend
      if (url.contains('photo-1610832958506-aa56338406cd') || 
          url.contains('photo-1550583724-125581f77833')) {
        return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800';
      }

      final baseAppUrl = AppConfig.baseUrl.split('/api/').first;
      
      if (url.startsWith('http')) {
        // If it's a localhost/127.0.0.1 URL from the backend, 
        // replace it with our configured baseAppUrl to ensure it works on emulators/devices.
        if (url.contains('://127.0.0.1') || url.contains('://localhost')) {
          final path = Uri.parse(url).path;
          return '$baseAppUrl$path';
        }
        return url;
      }
      
      final cleanUrl = url.startsWith('/') ? url : '/$url';
      return '$baseAppUrl$cleanUrl';
    }

    List<String> extractDietaryLabels(dynamic value) {
      if (value is List) {
        return value
            .map((entry) => entry.toString().trim())
            .where((entry) => entry.isNotEmpty)
            .toList();
      }

      if (value is Map) {
        return value.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key.toString())
            .map((entry) => entry.replaceFirst(RegExp(r'^is_'), ''))
            .map((entry) => entry.replaceAll('_', ' ').trim())
            .where((entry) => entry.isNotEmpty)
            .toList();
      }

      return const <String>[];
    }

    // ── Images: from photos array ─────────────────────────────────────────
    final photosRaw = json['photos'] as List<dynamic>? ?? [];
    var images = photosRaw
        .map((p) => (p as Map<String, dynamic>)['photo_url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .map(normalizeUrl)
        .toList();
    if (images.isEmpty) {
      final fallback = json['primary_photo_url'] as String?;
      if (fallback != null && fallback.isNotEmpty) {
        images = [normalizeUrl(fallback)];
      }
    }

    // ── Description ───────────────────────────────────────────────────────
    final description = json['description'] as String? ??
        json['description_fr'] as String? ??
        json['title'] as String? ??
        '';

    // ── Address: best effort from merchant_info ───────────────────────────
    final address = merchantInfo['wilaya']?.toString() ?? '';

    // ── What you get: dietary_flags + allergens as bullet list ────────────
    final dietaryFlags = extractDietaryLabels(json['dietary_flags']);
    final allergens = (json['allergens'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final whatYouGet = [...dietaryFlags, ...allergens];

    // ── Merchant badge: verified if trust_score > 0 ───────────────────────
    final trustScore = (merchantInfo['trust_score'] as num? ?? 0).toDouble();
    final badges = trustScore > 0 ? ['verified'] : <String>[];

    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final reviews = rawReviews.map((r) {
      final rMap = r as Map<String, dynamic>;
      return ListingReview(
        id: rMap['id']?.toString() ?? '',
        userName: rMap['user_name']?.toString() ?? rMap['consumer_name']?.toString() ?? 'Anonymous',
        rating: (rMap['rating'] as num?)?.toDouble() ?? 5.0,
        date: rMap['created_at']?.toString() ?? '',
        comment: rMap['comment']?.toString() ?? '',
        helpfulCount: (rMap['helpful_count'] as num?)?.toInt() ?? 0,
        merchantReply: rMap['merchant_reply']?.toString(),
      );
    }).toList();
    final rawFaqs = json['faqs'] as List<dynamic>? ?? [];
    final faqs = rawFaqs.map((f) {
      final fMap = f as Map<String, dynamic>;
      return ListingFAQ(
        question: fMap['question']?.toString() ?? '',
        answer: fMap['answer']?.toString() ?? '',
      );
    }).toList();
    
    final merchantLoc = merchantInfo['location'] as Map<String, dynamic>? ?? {};
    final lat = (merchantLoc['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (merchantLoc['longitude'] as num?)?.toDouble() ?? 0.0;
    final merchantAddress = merchantInfo['address']?.toString() ?? merchantInfo['wilaya']?.toString() ?? json['merchant_address']?.toString() ?? '';

    String? getString(Map<String, dynamic> m, String key) {
      final v = m[key]?.toString();
      return (v != null && v.isNotEmpty) ? v : null;
    }

    final merchantId = getString(merchantInfo, 'id') ?? getString(json, 'merchant_id') ?? '';
    final merchantName = getString(merchantInfo, 'business_name') ?? 
                         getString(merchantInfo, 'name') ?? 
                         getString(json, 'merchant_name') ?? 
                         'Merchant';
    final merchantLogo = normalizeUrl(getString(merchantInfo, 'logo_url') ?? 
                                    getString(merchantInfo, 'logo') ?? 
                                    getString(merchantInfo, 'business_logo') ?? 
                                    getString(merchantInfo, 'avatar_url') ?? 
                                    getString(json, 'merchant_logo_url') ?? 
                                    '');
    final merchantPhone = getString(merchantInfo, 'phone') ?? getString(json, 'merchant_phone') ?? '';
    final merchantWilaya = getString(merchantInfo, 'wilaya') ?? getString(json, 'merchant_wilaya') ?? '';

    return ListingExtraDetails(
      id: json['id']?.toString() ?? '',
      description: description,
      images: images,
      phone: merchantPhone,
      address: merchantAddress,
      whatYouGet: whatYouGet,
      merchant: MerchantDetails(
        id: merchantId,
        name: merchantName,
        logoUrl: merchantLogo,
        coverImageUrl: normalizeUrl(getString(merchantInfo, 'cover_image_url') ?? 
                                   getString(merchantInfo, 'cover_image') ?? 
                                   getString(merchantInfo, 'banner_url') ?? 
                                   ''),
        address: merchantAddress,
        phone: merchantPhone,
        wilaya: merchantWilaya,
        lat: lat,
        lng: lng,
        badges: badges,
        bio: merchantInfo['description']?.toString() ?? merchantInfo['business_type']?.toString() ?? '',
        mealsSaved: (merchantInfo['meals_saved'] as num? ?? merchantInfo['total_orders_fulfilled'] as num? ?? 0).toInt(),
        fulfillmentRate: (trustScore <= 5.0 ? trustScore * 20 : trustScore).clamp(0, 100).toInt(),
        memberSince: merchantInfo['member_since']?.toString() ?? '2023',
        averageRating: (merchantInfo['average_rating'] as num? ?? 0.0).toDouble(),
        totalReviews: (merchantInfo['total_reviews'] as num? ?? 0).toInt(),
      ),
      reviews: reviews,
      faqs: faqs,
      userHasReserved: userHasReserved,
    );
  }
}
