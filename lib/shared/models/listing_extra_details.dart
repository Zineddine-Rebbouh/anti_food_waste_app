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
}
