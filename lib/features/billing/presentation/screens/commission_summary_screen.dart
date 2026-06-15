import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class CommissionSummaryScreen extends StatefulWidget {
  const CommissionSummaryScreen({super.key});

  @override
  State<CommissionSummaryScreen> createState() => _CommissionSummaryScreenState();
}

class _CommissionSummaryScreenState extends State<CommissionSummaryScreen> {
  static const _primaryGreen = AppTheme.primary;
  static const _amber = Color(0xFFF59E0B);
  static const _blue = Color(0xFF3B82F6);
  static const _red = Color(0xFFEF4444);

  final _currencyFmt = NumberFormat('#,##0.00', 'fr_DZ');
  final _dateFmt = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    final cubit = context.read<BillingCubit>();
    if (cubit.state is BillingInitial) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<BillingCubit, BillingState>(
        builder: (context, state) {
          if (state is BillingLoading || state is BillingInitial) {
            return _buildLoading();
          }
          if (state is BillingError) {
            return _buildError(context, state.message);
          }
          if (state is BillingLoaded) {
            return _buildContent(context, state);
          }
          return _buildLoading();
        },
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, size: 48, color: _red),
              ),
              const SizedBox(height: 20),
              const Text(
                'Failed to load commissions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.read<BillingCubit>().load(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main content ─────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, BillingLoaded state) {
    final commissions = state.commissions;
    final totalPending = commissions
        .where((c) => c.status == 'pending')
        .fold<double>(0, (sum, c) => sum + c.commissionAmountDzd);
    final totalSettled = commissions
        .where((c) => c.status == 'settled')
        .fold<double>(0, (sum, c) => sum + c.commissionAmountDzd);
    final commissionRate = commissions.isNotEmpty ? commissions.first.commissionRate : null;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, totalPending, totalSettled),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildSummaryCards(commissions, totalPending, totalSettled, commissionRate),
              const SizedBox(height: 24),
              _buildSectionHeader(commissions.length),
            ],
          ),
        ),
        if (commissions.isEmpty)
          SliverFillRemaining(child: _buildEmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _CommissionCard(
                  entry: commissions[index],
                  currencyFmt: _currencyFmt,
                  dateFmt: _dateFmt,
                ),
              ),
              childCount: commissions.length,
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  // ── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context, double totalPending, double totalSettled) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _primaryGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => context.read<BillingCubit>().load(),
          tooltip: 'Refresh',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, Color(0xFF0D2119)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMMISSION LEDGER',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_currencyFmt.format(totalPending)} DZD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pending commissions owed to Tawfir',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: const Text(
          'My Commissions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────────────

  Widget _buildSummaryCards(
    List<CommissionLedger> commissions,
    double totalPending,
    double totalSettled,
    double? commissionRate,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline_rounded, color: _blue, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commissionRate != null
                            ? 'Platform commission: ${commissionRate.toStringAsFixed(1)}% per completed order'
                            : 'Platform commission applied to each completed order',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Commission is auto-calculated when a consumer collects their order via QR scan.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Pending',
                  value: '${_currencyFmt.format(totalPending)} DZD',
                  icon: Icons.hourglass_top_rounded,
                  color: _amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Settled',
                  value: '${_currencyFmt.format(totalSettled)} DZD',
                  icon: Icons.check_circle_rounded,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Total Orders',
                  value: commissions.length.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: _blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Text(
            'ALL ENTRIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade400,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet_outlined, size: 56, color: _primaryGreen.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No commissions yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 10),
            Text(
              'Commission entries are created automatically when consumers collect their orders via QR scan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _CommissionCard extends StatelessWidget {
  final CommissionLedger entry;
  final NumberFormat currencyFmt;
  final DateFormat dateFmt;

  const _CommissionCard({
    required this.entry,
    required this.currencyFmt,
    required this.dateFmt,
  });

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'settled': Color(0xFF2D8659),
    'waived': Color(0xFF6B7280),
  };

  static const _statusLabels = {
    'pending': 'Pending',
    'settled': 'Settled',
    'waived': 'Waived',
  };

  static const _statusIcons = {
    'pending': Icons.hourglass_top_rounded,
    'settled': Icons.check_circle_rounded,
    'waived': Icons.not_interested_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[entry.status] ?? Colors.grey;
    final statusLabel = _statusLabels[entry.status] ?? entry.status;
    final statusIcon = _statusIcons[entry.status] ?? Icons.circle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.listingTitle.isNotEmpty ? entry.listingTitle : 'Food Listing',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Consumer: ${entry.consumerName.isNotEmpty ? entry.consumerName : 'Unknown'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),
          // Financial details row
          Row(
            children: [
              _DetailChip(
                label: 'Order Value',
                value: '${currencyFmt.format(entry.orderAmountDzd)} DZD',
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              _DetailChip(
                label: 'Rate',
                value: '${entry.commissionRate.toStringAsFixed(1)}%',
                color: const Color(0xFF3B82F6),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Commission Due',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${currencyFmt.format(entry.commissionAmountDzd)} DZD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dateFmt.format(entry.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color.withOpacity(0.7))),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
