-- 1. Update Merchant Profile with Logo and Cover
UPDATE users_merchant 
SET 
    logo_url = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
    cover_image_url = 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=1200&h=600&fit=crop',
    description = 'Authentic Algerian bakery serving fresh traditional bread and pastries daily. We are committed to reducing food waste by offering our surplus at great prices.'
WHERE user_id = 'fe1ce925-e3be-458e-8613-703d5e9235a5';

-- 2. Create a New Listing for this Merchant
INSERT INTO listings_listing (
    id, created_at, updated_at, title, title_ar, title_fr, 
    description, description_ar, description_fr, 
    original_price, discounted_price, currency, 
    quantity_total, quantity_available, unit, 
    freshness_grade, status, pickup_start, pickup_end, 
    is_donation, allergens, dietary_flags, category_id, merchant_id
) 
SELECT 
    gen_random_uuid(), NOW(), NOW(), 'Traditional Bread Basket', 'سلة خبز تقليدي', 'Panier de pain traditionnel',
    'A mix of fresh traditional Algerian bread including Msemen and Kesra.', 'مزيج من الخبز الجزائري التقليدي الطازج بما في ذلك المسمن والكسرة.', 'Un mélange de pain algérien traditionnel frais, y compris le Msemen et la Kesra.',
    800.00, 350.00, 'DZD',
    10, 10, 'basket',
    'A', 'active', NOW() + INTERVAL '1 hour', NOW() + INTERVAL '4 hours',
    false, '["gluten"]', '{"is_halal": true}', 25, 'fe1ce925-e3be-458e-8613-703d5e9235a5'
WHERE NOT EXISTS (
    SELECT 1 FROM listings_listing WHERE title = 'Traditional Bread Basket' AND merchant_id = 'fe1ce925-e3be-458e-8613-703d5e9235a5'
);

-- 3. Create an Order for this Listing by the Consumer
INSERT INTO orders_order (
    id, created_at, updated_at, quantity, unit_price, total_price, 
    currency, order_status, payment_method, payment_status, 
    qr_hash, pickup_code, cancellation_reason, cancelled_by, notes,
    consumer_id, listing_id, merchant_id
)
SELECT 
    gen_random_uuid(), NOW(), NOW(), 1, 350.00, 350.00, 
    'DZD', 'reserved', 'cash', 'pending', 
    'test_qr_hash_' || md5(random()::text), 'SF-TEST', '', '', 'Testing order flow',
    'c2091ad1-1c50-4275-8fe5-82fb44553dce', l.id, 'fe1ce925-e3be-458e-8613-703d5e9235a5'
FROM listings_listing l 
WHERE l.title = 'Traditional Bread Basket' 
AND l.merchant_id = 'fe1ce925-e3be-458e-8613-703d5e9235a5'
ORDER BY l.created_at DESC 
LIMIT 1;
