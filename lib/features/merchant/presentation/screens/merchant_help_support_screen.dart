import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantHelpSupportScreen extends StatefulWidget {
  const MerchantHelpSupportScreen({super.key});

  @override
  State<MerchantHelpSupportScreen> createState() =>
      _MerchantHelpSupportScreenState();
}

class _MerchantHelpSupportScreenState
    extends State<MerchantHelpSupportScreen> {
  final Set<int> _expanded = {};

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color backgroundColor = Colors.white;

  List<_FaqItem> _getFaqs(AppLocalizations l10n) {
    return [
      _FaqItem(question: l10n.faq_commission_q, answer: l10n.faq_commission_a),
      _FaqItem(question: l10n.faq_paid_q, answer: l10n.faq_paid_a),
      _FaqItem(question: l10n.faq_noshow_q, answer: l10n.faq_noshow_a),
      _FaqItem(question: l10n.faq_add_q, answer: l10n.faq_add_a),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final faqs = _getFaqs(l10n);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: 24),
            
            _buildSectionHeader(l10n.quick_support_label),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _ContactCard(icon: Icons.chat_bubble_outline, label: l10n.live_chat_label, color: primaryGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _ContactCard(icon: Icons.phone_outlined, label: l10n.call_us_label, color: const Color(0xFF6366F1))),
                  const SizedBox(width: 12),
                  Expanded(child: _ContactCard(icon: Icons.email_outlined, label: l10n.email_label, color: const Color(0xFFF59E0B))),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(l10n.tutorials_label),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _TutorialCard(icon: Icons.add_box_outlined, title: l10n.create_listing_label, color: primaryGreen),
                  const SizedBox(width: 12),
                  _TutorialCard(icon: Icons.qr_code_outlined, title: l10n.scan_qr_codes_label, color: const Color(0xFF6366F1)),
                  const SizedBox(width: 12),
                  _TutorialCard(icon: Icons.payments_outlined, title: l10n.payout_info_label, color: const Color(0xFFF59E0B)),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(l10n.faqs_title),
            _buildFaqSection(faqs),
            
            const SizedBox(height: 48),
            const Center(
              child: Column(
                children: [
                  Text('SaveFood DZ Support', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD1D5DB))),
                  SizedBox(height: 4),
                  Text('support@savefood.dz', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primaryGreen)),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.04),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      l10n.help_support_title,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      l10n.help_support_subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _buildFaqSection(List<_FaqItem> faqs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: faqs.asMap().entries.map((e) {
          final i = e.key;
          final faq = e.value;
          final isExpanded = _expanded.contains(i);
          return Column(
            children: [
              if (i > 0) Divider(height: 1, color: Colors.grey[100], indent: 20, endIndent: 20),
              ListTile(
                onTap: () => setState(() => isExpanded ? _expanded.remove(i) : _expanded.add(i)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(faq.question, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isExpanded ? primaryGreen : const Color(0xFF111827))),
                trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[400]),
                subtitle: isExpanded ? Padding(padding: const EdgeInsets.only(top: 12), child: Text(faq.answer, style: TextStyle(color: Colors.grey[600], height: 1.5))) : null,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ContactCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _TutorialCard({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  _FaqItem({required this.question, required this.answer});
}



