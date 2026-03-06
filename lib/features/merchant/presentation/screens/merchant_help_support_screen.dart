import 'package:flutter/material.dart';

class MerchantHelpSupportScreen extends StatefulWidget {
  const MerchantHelpSupportScreen({super.key});

  @override
  State<MerchantHelpSupportScreen> createState() =>
      _MerchantHelpSupportScreenState();
}

class _MerchantHelpSupportScreenState
    extends State<MerchantHelpSupportScreen> {
  final Set<int> _expanded = {};

  static const _faqs = [
    _FaqItem(
      question: 'How does the commission work?',
      answer:
          'SaveFood DZ charges a 12% commission on each completed sale. For example, if you sell at 100 DZD, you keep 88 DZD. Commission is deducted automatically before payout — there are no hidden fees.',
    ),
    _FaqItem(
      question: 'When do I get paid?',
      answer:
          'Earnings are paid out every Tuesday and Friday. You can view your upcoming payout schedule in Earnings & Payouts. Minimum payout threshold is 500 DZD.',
    ),
    _FaqItem(
      question: 'What if a customer doesn\'t show up?',
      answer:
          'If a customer with an online payment doesn\'t collect their order within 30 minutes of the pickup window closing, the order is automatically cancelled and credited back to the customer. For Cash on Pickup orders, simply wait for pick-up time and close the listing if uncollected.',
    ),
    _FaqItem(
      question: 'How do I add a new listing?',
      answer:
          'Tap the + button on your Home screen or the Listings tab. Follow the 5-step wizard: add photos, set the title and category, price your item, set quantity and pickup times, then publish.',
    ),
    _FaqItem(
      question: 'How is my Trust Score calculated?',
      answer:
          'Your Trust Score (0–100) reflects completion rate, accuracy of listing descriptions, customer feedback, and response speed. Higher scores get better listing visibility and lower commission rates over time.',
    ),
    _FaqItem(
      question: 'Can I donate food to charities?',
      answer:
          'Yes! When managing a listing, tap "Donate to Charity". Verified charity partners like the Algerian Red Crescent can then request the items. Donations are commission-free and contribute to your eco-impact score.',
    ),
    _FaqItem(
      question: 'What food categories are supported?',
      answer:
          'Bakery, Pastry, Restaurant meals, Groceries, Fruits & Vegetables, Dairy, Meat & Poultry, Beverages, and Pre-packaged goods. Contact support to add a new category.',
    ),
    _FaqItem(
      question: 'How do I handle a QR code issue?',
      answer:
          'If a customer\'s QR code won\'t scan, use the manual entry option on the scanner screen. Type the order number (format: SF-XXXXXX) to look up and confirm the order.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: const Color(0xFF2D8659),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'Help & Support',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'We\'re here to help',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Quick contact cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: _ContactCard(
                        icon: Icons.chat_bubble_outline,
                        label: 'Live Chat',
                        subtitle: 'Avg. 2 min response',
                        color: const Color(0xFF2D8659),
                        onTap: () {},
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _ContactCard(
                        icon: Icons.phone_outlined,
                        label: 'Call Us',
                        subtitle: '+213 21 000 111',
                        color: const Color(0xFF6366F1),
                        onTap: () {},
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _ContactCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        subtitle: 'support@savefood.dz',
                        color: const Color(0xFFF59E0B),
                        onTap: () {},
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Tutorials section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Getting Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      _TutorialCard(
                        icon: Icons.add_box_outlined,
                        title: 'Create Your First Listing',
                        color: Color(0xFF2D8659),
                      ),
                      SizedBox(width: 12),
                      _TutorialCard(
                        icon: Icons.qr_code_outlined,
                        title: 'Scanning & Verifying Orders',
                        color: Color(0xFF6366F1),
                      ),
                      SizedBox(width: 12),
                      _TutorialCard(
                        icon: Icons.payments_outlined,
                        title: 'Understanding Payouts',
                        color: Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 12),
                      _TutorialCard(
                        icon: Icons.volunteer_activism_outlined,
                        title: 'Donating to Charities',
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // FAQ
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: _faqs.asMap().entries.map((e) {
                        final i = e.key;
                        final faq = e.value;
                        final isExpanded = _expanded.contains(i);
                        return Column(
                          children: [
                            if (i > 0)
                              const Divider(
                                  height: 1,
                                  color: Color(0xFFF3F4F6),
                                  indent: 16),
                            InkWell(
                              borderRadius: BorderRadius.only(
                                topLeft: i == 0
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                                topRight: i == 0
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                                bottomLeft: i == _faqs.length - 1 &&
                                        !isExpanded
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                                bottomRight: i == _faqs.length - 1 &&
                                        !isExpanded
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                              ),
                              onTap: () => setState(() {
                                if (isExpanded) {
                                  _expanded.remove(i);
                                } else {
                                  _expanded.add(i);
                                }
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        faq.question,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isExpanded
                                              ? const Color(0xFF2D8659)
                                              : const Color(0xFF374151),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: const Color(0xFF9CA3AF),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 14),
                                child: Text(
                                  faq.answer,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Footer
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'SaveFood DZ Business App',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'support@savefood.dz',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF2D8659)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 9, color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _TutorialCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
