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
  final String name;
  final String? logoUrl;
  final List<String> badges;
  final String bio;
  final int mealsSaved;
  final int fulfillmentRate;
  final String memberSince;

  MerchantDetails({
    required this.name,
    this.logoUrl,
    required this.badges,
    required this.bio,
    required this.mealsSaved,
    required this.fulfillmentRate,
    required this.memberSince,
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
  });

  /// Builds a [ListingExtraDetails] from a backend [ListingDetailSerializer] response.
  factory ListingExtraDetails.fromDetailJson(Map<String, dynamic> json) {
    final merchantInfo = json['merchant_info'] as Map<String, dynamic>? ?? {};

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
    List<String> images = photosRaw
        .map((p) => (p as Map<String, dynamic>)['photo_url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
    if (images.isEmpty) {
      final fallback = json['primary_photo_url'] as String?;
      if (fallback != null && fallback.isNotEmpty) images = [fallback];
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
    return ListingExtraDetails(
      id: json['id']?.toString() ?? '',
      description: description,
      images: images,
      phone: '',
      address: address,
      whatYouGet: whatYouGet,
      merchant: MerchantDetails(
        name: merchantInfo['business_name']?.toString() ?? '',
        logoUrl: merchantInfo['logo_url']?.toString(),
        badges: badges,
        bio: merchantInfo['business_type']?.toString() ?? '',
        mealsSaved: 0,
        fulfillmentRate: (trustScore * 20).clamp(0, 100).toInt(),
        memberSince: '',
      ),
      reviews: reviews,
      faqs: faqs,
    );
  }
}

