import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/invoice_history_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  late DateTime _endDate;
  String _paymentMethod = 'bank_transfer';

  @override
  void initState() {
    super.initState();
    context.read<BillingCubit>().load();
    _endDate = _startDate.add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D8659),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = picked.add(const Duration(days: 30));
      });
    }
  }

  void _submitUpgradeRequest(BillingLoaded state, SubscriptionPlan standardPlan) {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2D8659)),
      ),
    );

    context
        .read<BillingCubit>()
        .requestUpgrade(
          planId: standardPlan.id,
          periodStart: _startDate,
          periodEnd: _endDate,
          paymentMethod: _paymentMethod,
          referenceNumber: _referenceController.text.trim(),
          notes: _notesController.text.trim(),
        )
        .then((_) {
      Navigator.pop(context); // Close loading indicator
      _referenceController.clear();
      _notesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription upgrade request submitted successfully!'),
          backgroundColor: Color(0xFF2D8659),
        ),
      );
    }).catchError((err) {
      Navigator.pop(context); // Close loading indicator
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Request Failed'),
          content: Text(err.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: Color(0xFF2D8659))),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Billing & Subscription',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D8659),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<BillingCubit, BillingState>(
        builder: (context, state) {
          if (state is BillingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D8659)),
            );
          }
          if (state is BillingError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<BillingCubit>().load(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D8659),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! BillingLoaded) {
            return const SizedBox.shrink();
          }

          final subscription = state.subscription;
          final plans = state.plans;
          final payments = state.payments;

          final standardPlan = plans.firstWhere(
            (p) => p.slug == 'standard',
            orElse: () => SubscriptionPlan(
              id: 2,
              name: 'Standard Plan',
              slug: 'standard',
              monthlyPriceDzd: 2000.00,
              canReceiveDonations: true,
              isActive: true,
            ),
          );

          final showUpgradeForm =
              subscription.status == 'trial' || subscription.status == 'suspended';

          return RefreshIndicator(
            onRefresh: () => context.read<BillingCubit>().load(),
            color: const Color(0xFF2D8659),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCurrentPlanCard(subscription),
                  if (showUpgradeForm) _buildUpgradeFormCard(state, standardPlan),
                  _buildPaymentHistorySection(payments),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPlanCard(MerchantSubscription sub) {
    final isTrial = sub.status == 'trial';
    final isActive = sub.status == 'active';
    final isSuspended = sub.status == 'suspended';
    final isPastDue = sub.status == 'past_due';

    Color statusColor = Colors.grey;
    if (isTrial) statusColor = Colors.blue;
    if (isActive) statusColor = Colors.green;
    if (isSuspended) statusColor = Colors.red;
    if (isPastDue) statusColor = Colors.orange;

    final formattedEnd = sub.currentPeriodEnd != null
        ? DateFormat('MMMM d, yyyy').format(sub.currentPeriodEnd!)
        : (sub.trialEndsAt != null ? DateFormat('MMMM d, yyyy').format(sub.trialEndsAt!) : 'N/A');

    final limitText = sub.plan.maxActiveListings == null
        ? 'Unlimited Listings'
        : '${sub.activeListingCount} / ${sub.plan.maxActiveListings} Active Listings';

    final percent = sub.plan.maxActiveListings == null
        ? 0.0
        : (sub.activeListingCount / sub.plan.maxActiveListings!).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [const Color(0xFF1B5E20), const Color(0xFF2D8659)]
              : (isTrial
                  ? [const Color(0xFF0D47A1), const Color(0xFF1976D2)]
                  : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sub.plan.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Text(
                  sub.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${sub.plan.monthlyPriceDzd.toStringAsFixed(0)} DZD / Month',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTrial ? 'Trial Period Ends' : 'Renewal Date',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                formattedEnd,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (sub.daysRemaining != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Days Remaining',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${sub.daysRemaining} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text(
            limitText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (sub.plan.maxActiveListings != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percent > 0.85 ? Colors.orange : Colors.white,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpgradeFormCard(BillingLoaded state, SubscriptionPlan standardPlan) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.rocket_launch_rounded, color: Color(0xFF2D8659), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upgrade to ${standardPlan.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock unlimited active listings and accept donations directly from charity organizations for only ${standardPlan.monthlyPriceDzd.toStringAsFixed(0)} DZD per month.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _selectStartDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Desired Start Date',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM d, yyyy').format(_startDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF2D8659), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date (Auto-calculated, 30 days)',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM d, yyyy').format(_endDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.lock_clock_rounded, color: Colors.grey, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D8659), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank / CCP Transfer')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash Payment')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _paymentMethod = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'Transfer Reference / Receipt Number',
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  hintText: 'Enter bank transaction ID or receipt #',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D8659), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter transaction/receipt reference';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D8659), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _submitUpgradeRequest(state, standardPlan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8659),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Upgrade Request',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistorySection(List<SubscriptionPayment> payments) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Invoices',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (payments.length > 3)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoiceHistoryScreen(payments: payments),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFF2D8659), fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'No payment history found',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length > 3 ? 3 : payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final payment = payments[idx];
                return _buildPaymentTile(payment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(SubscriptionPayment payment) {
    Color statusColor = Colors.orange;
    if (payment.status == 'paid') statusColor = Colors.green;
    if (payment.status == 'refunded') statusColor = Colors.blue;
    if (payment.status == 'waived') statusColor = Colors.grey;

    final periodStr =
        '${DateFormat('MMM d').format(payment.periodStart)} - ${DateFormat('MMM d, yyyy').format(payment.periodEnd)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D8659).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_rounded, color: Color(0xFF2D8659)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.plan.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  periodStr,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                if (payment.referenceNumber.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${payment.referenceNumber}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${payment.amountDzd.toStringAsFixed(0)} DZD',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
