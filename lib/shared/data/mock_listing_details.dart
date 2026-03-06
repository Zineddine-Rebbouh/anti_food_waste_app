import '../models/listing_extra_details.dart';

final Map<String, ListingExtraDetails> mockListingExtraDetails = {
  'r1': ListingExtraDetails(
    id: 'r1',
    description:
        'A surprise bag of fresh baguettes baked today. Perfect for dinner or sandwiches. High quality artisanal bread from one of the best bakeries in Algiers.',
    images: [
      'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
      'https://images.unsplash.com/photo-1598143153003-7237c1a9a2c5?w=800',
      'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?w=800',
    ],
    phone: '+213 555 12 34 56',
    address: '12 Rue Didouche Mourad, Algiers Center',
    whatYouGet: [
      '3-4 Fresh Baguettes',
      'Occasional pastry surprise',
      'Reusable paper bag',
    ],
    merchant: MerchantDetails(
      name: 'Boulangerie El Khobz',
      logoUrl: null,
      badges: ['top_saver', 'verified'],
      bio:
          'Family-owned bakery since 1985, committed to traditional Algerian baking methods and reducing food waste.',
      mealsSaved: 1240,
      fulfillmentRate: 98,
      memberSince: 'March 2023',
    ),
    reviews: [
      ListingReview(
        id: 'rev1',
        userName: 'Ahmed K.',
        rating: 5,
        date: '2 days ago',
        comment:
            'Best baguettes in town! They were still warm when I picked them up. Amazing value for money.',
        helpfulCount: 12,
        merchantReply: 'Thank you Ahmed! We are glad you enjoyed them.',
      ),
      ListingReview(
        id: 'rev2',
        userName: 'Sara B.',
        rating: 4,
        date: '1 week ago',
        comment: 'Very good bread, though the pickup window is a bit tight.',
        helpfulCount: 5,
      ),
    ],
    faqs: [
      ListingFAQ(
        question: 'When is the best time to pick up?',
        answer:
            'We recommend arriving 15 minutes before the end of the pickup window to ensure the best selection.',
      ),
      ListingFAQ(
        question: 'Are there any allergens?',
        answer:
            'Our bread contains gluten. Please ask in-store for specific ingredients.',
      ),
    ],
  ),
  'r2': ListingExtraDetails(
    id: 'r2',
    description:
        'Premium sushi selection including maki, nigiri, and California rolls. Made fresh this evening with high-quality ingredients.',
    images: [
      'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800',
      'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?w=800',
    ],
    phone: '+213 21 45 67 89',
    address: 'Sidi Yahia Boulevard, Hydra, Algiers',
    whatYouGet: [
      '12-16 Pieces of mixed Sushi',
      'Soy sauce, ginger, and wasabi',
      'Chopsticks included',
    ],
    merchant: MerchantDetails(
      name: 'Yuki Sushi Algiers',
      logoUrl: null,
      badges: ['five_star', 'trending'],
      bio:
          'Authentic Japanese cuisine in the heart of Algiers. We believe fresh fish shouldn\'t go to waste.',
      mealsSaved: 850,
      fulfillmentRate: 95,
      memberSince: 'October 2023',
    ),
    reviews: [
      ListingReview(
        id: 'rev3',
        userName: 'Mohamed R.',
        rating: 5,
        date: '3 days ago',
        comment: 'Incredible quality for the price. This is a steal!',
        helpfulCount: 24,
      ),
    ],
    faqs: [
      ListingFAQ(
        question: 'Is the fish fresh?',
        answer:
            'Yes, all our sushi is prepared fresh daily. These surplus items are from the evening service.',
      ),
    ],
  ),
};
