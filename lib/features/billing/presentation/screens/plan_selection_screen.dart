import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/payment_instructions_screen.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

/// Page 1 of the subscription onboarding flow.
/// Shown when: trial expires, subscription lapses, or merchant taps "Subscribe".
/// Navigates to [PaymentInstructionsScreen] on "Subscribe Now".
class PlanSelectionScreen extends StatelessWidget {
  const PlanSelectionScreen({super.key});

  static const _green = AppTheme.primary;
  static const _amber = Color(0xFFF59E0B);
  static const _blue = Color(0xFF3B82F6);

  String _t(BuildContext context, String en, String fr, String ar) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'fr':
        return fr;
      case 'ar':
        return ar;
      default:
        return en;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<BillingCubit, BillingState>(
        builder: (context, state) {
          if (state is BillingLoading || state is BillingInitial) {
            return const Center(child: CircularProgressIndicator(color: _green));
          }
          if (state is BillingError) {
            return _buildError(context, state.message);
          }
          if (state is! BillingLoaded) {
            return const SizedBox.shrink();
          }

          final sub = state.subscription;
          final isTrial = sub.status == 'trial';
          final isExpired = sub.status == 'suspended' || sub.status == 'past_due';
          final daysLeft = sub.daysRemaining;

          final standardPlan = state.plans.firstWhere(
            (p) => p.slug == 'standard',
            orElse: () => SubscriptionPlan(
              id: 2,
              name: 'Standard Plan',
              slug: 'standard',
              monthlyPriceDzd: 2000.0,
              canReceiveDonations: true,
              isActive: true,
            ),
          );

          final trialPlan = state.plans.firstWhere(
            (p) => p.slug == 'trial',
            orElse: () => SubscriptionPlan(
              id: 1,
              name: 'Trial',
              slug: 'trial',
              monthlyPriceDzd: 0.0,
              maxActiveListings: 10,
              canReceiveDonations: false,
              isActive: true,
            ),
          );

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Status pill
                    _buildStatusPill(context, isTrial, isExpired, daysLeft),
                    const SizedBox(height: 24),

                    // Trial card
                    _buildTrialCard(context, trialPlan, isTrial, daysLeft),
                    const SizedBox(height: 16),

                    // Standard plan card
                    _buildStandardCard(context, standardPlan, state),
                    const SizedBox(height: 32),

                    // Commission explanation
                    _buildCommissionExplainer(context),
                    const SizedBox(height: 24),

                    // Support link
                    _buildSupportLink(context),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: _green,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
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
              Positioned(
                top: -20,
                right: -20,
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
                        'SUBSCRIPTION',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose Your Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock full access to Tawfir and start reaching customers.',
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
     
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, bool isTrial, bool isExpired, int? daysLeft) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (isExpired) {
      bg = const Color(0xFFEF4444).withOpacity(0.12);
      fg = const Color(0xFFEF4444);
      label = _t(context, 'Subscription Expired', 'Abonnement expiré', 'انتهى الاشتراك');
      icon = Icons.cancel_rounded;
    } else if (isTrial && daysLeft != null && daysLeft <= 7) {
      bg = _amber.withOpacity(0.12);
      fg = _amber;
      label = _t(context, 'Trial ends in $daysLeft days', 'Essai se termine dans $daysLeft jours', 'التجربة تنتهي خلال $daysLeft أيام');
      icon = Icons.hourglass_top_rounded;
    } else if (isTrial) {
      bg = _blue.withOpacity(0.10);
      fg = _blue;
      label = _t(context, 'Trial Active — ${daysLeft ?? "?"} days left', 'Essai actif — ${daysLeft ?? "?"} jours', 'تجربة نشطة — ${daysLeft ?? "?"} أيام');
      icon = Icons.rocket_launch_rounded;
    } else {
      bg = _green.withOpacity(0.10);
      fg = _green;
      label = _t(context, 'Active Subscription', 'Abonnement actif', 'اشتراك نشط');
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTrialCard(BuildContext context, SubscriptionPlan plan, bool isTrial, int? daysLeft) {
    final isCurrent = isTrial;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent ? _blue.withOpacity(0.4) : Colors.grey.shade200,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _blue.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.rocket_launch_rounded, color: _blue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(context, 'Trial', 'Essai', 'تجريبي'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    ),
                    Text(
                      _t(context, 'Free for 30 days', 'Gratuit 30 jours', 'مجاني لمدة 30 يومًا'),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _t(context, 'Current', 'Actuel', 'الحالي'),
                    style: const TextStyle(color: _blue, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _FeatureRow(text: _t(context, 'Up to 10 active listings', 'Jusqu\'à 10 annonces', 'حتى 10 إعلانات')),
          _FeatureRow(text: _t(context, 'Basic support', 'Assistance de base', 'دعم أساسي')),
          _FeatureRow(text: _t(context, '10% commission on each sale', '10% de commission par vente', 'عمولة 10% على كل عملية بيع')),
        ],
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context, SubscriptionPlan plan, BillingLoaded state) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF0D2119)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text(
                      '${plan.monthlyPriceDzd.toStringAsFixed(0)} DZD / ${_t(context, 'month', 'mois', 'شهر')}',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  _t(context, 'RECOMMENDED', 'RECOMMANDÉ', 'موصى به'),
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          _FeatureRow(text: _t(context, 'Unlimited active listings', 'Annonces illimitées', 'إعلانات غير محدودة'), light: true),
          _FeatureRow(text: _t(context, 'Priority support', 'Assistance prioritaire', 'دعم أولوية'), light: true),
          _FeatureRow(text: _t(context, 'Commission earnings tracking', 'Suivi des commissions', 'تتبع العمولات'), light: true),
          _FeatureRow(text: _t(context, 'Sponsored listing eligibility', 'Éligible aux annonces sponsorisées', 'أهلية للإعلانات الممولة'), light: true),
          _FeatureRow(text: _t(context, 'Receive charity donations', 'Recevez des dons caritatifs', 'استلام التبرعات الخيرية'), light: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<BillingCubit>(),
                      child: PaymentInstructionsScreen(plan: plan),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _t(context, 'Subscribe Now', 'S\'abonner maintenant', 'اشترك الآن'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionExplainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _amber.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.info_outline_rounded, color: _amber, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                _t(context, 'How commission works', 'Comment fonctionne la commission', 'كيف تعمل العمولة'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _t(
              context,
              'We take 10% of each successful sale. This is tracked automatically when a consumer collects their order via QR scan, and settled monthly along with your subscription.',
              'Nous prenons 10% de chaque vente réussie. Ceci est suivi automatiquement lors de la collecte et réglé mensuellement avec votre abonnement.',
              'نأخذ 10٪ من كل عملية بيع ناجحة. يتم تتبع ذلك تلقائيًا عند استلام الطلب عبر مسح QR، ويُسدَّد شهريًا مع اشتراكك.',
            ),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: _amber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _t(
                      context,
                      'Example: Sell a listing for 500 DZD → Tawfir earns 50 DZD → You keep 450 DZD.',
                      'Exemple : Vendez pour 500 DZD → Tawfir gagne 50 DZD → Vous gardez 450 DZD.',
                      'مثال: بعت بـ 500 دج ← تواصل تكسب 50 دج ← أنت تحتفظ بـ 450 دج.',
                    ),
                    style: const TextStyle(fontSize: 12, color: _amber, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Navigate to help/support screen
          Navigator.pushNamed(context, '/help');
        },
        child: Text(
          _t(context, 'Questions? Contact support', 'Des questions ? Contactez le support', 'أسئلة؟ تواصل مع الدعم'),
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _green,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Choose Your Plan', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<BillingCubit>().load(),
                style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final bool light;
  const _FeatureRow({required this.text, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: light ? Colors.white.withOpacity(0.8) : AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: light ? Colors.white.withOpacity(0.9) : const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
