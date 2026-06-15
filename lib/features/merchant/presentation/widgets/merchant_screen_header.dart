import 'package:flutter/material.dart';

class MerchantScreenHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback onAction;
  final TabController tabController;
  final List<Widget> tabs;

  const MerchantScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onAction,
    required this.tabController,
    required this.tabs,
  });

  static const Color _primaryGreen = Color(0xFF2D8659);
  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _primaryGreen,
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Tooltip(
                    message: actionTooltip,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shadowColor: _primaryGreen.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: Icon(actionIcon, size: 24),
                        onPressed: onAction,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.only(bottom: 12),
                indicator: const BoxDecoration(
                  color: Color(0xFFEAF5EF),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
                dividerColor: Colors.transparent,
                labelColor: _primaryGreen,
                unselectedLabelColor: _muted,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: tabs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
