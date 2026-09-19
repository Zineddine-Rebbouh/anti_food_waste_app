import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

/// Page 3: Pending Confirmation screen.
/// Shown after merchant submits a payment request.
class SubscriptionPendingScreen extends StatefulWidget {
  final SubscriptionPayment payment;

  const SubscriptionPendingScreen({super.key, required this.payment});

  @override
  State<SubscriptionPendingScreen> createState() => _SubscriptionPendingScreenState();
}

class _SubscriptionPendingScreenState extends State<SubscriptionPendingScreen> {
  bool _isCancelling = false;

  static const _green = AppTheme.primary;
  static const _amber = Color(0xFFF59E0B);

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

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t(context, 'Cancel Request?', 'Annuler la demande ?', 'إلغاء الطلب؟')),
        content: Text(_t(
          context,
          'Are you sure you want to cancel this pending subscription request?',
          'Êtes-vous sûr de vouloir annuler cette demande d\'abonnement en attente ?',
          'هل أنت متأكد من رغبتك في إلغاء طلب الاشتراك المعلق هذا؟',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t(context, 'No', 'Non', 'لا'), style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelRequest();
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest() async {
    setState(() => _isCancelling = true);
    try {
      await context.read<BillingCubit>().cancelRequest(widget.payment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t(context, 'Request cancelled successfully.', 'Demande annulée avec succès.', 'تم إلغاء الطلب بنجاح.')),
            backgroundColor: _green,
          ),
        );
        Navigator.pop(context); // Go back to Plan Selection screen
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t(context, 'Failed to cancel request: $e', 'Échec de l\'annulation : $e', 'فشل إلغاء الطلب: $e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodStr =
        '${DateFormat('MMMM d, yyyy').format(widget.payment.periodStart)} - ${DateFormat('MMMM d, yyyy').format(widget.payment.periodEnd)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _t(context, 'Pending Confirmation', 'Confirmation en attente', 'في انتظار التأكيد'),
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: _green,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusHeader(),
              const SizedBox(height: 24),
              _buildDetailsCard(periodStr),
              const SizedBox(height: 24),
              _buildNextStepsCard(),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  // Navigate to merchant home / main dashboard
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _t(context, 'Go to Dashboard', 'Aller au tableau de bord', 'الذهاب إلى لوحة التحكم'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              if (!_isCancelling)
                TextButton.icon(
                  onPressed: _confirmCancel,
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                  label: Text(
                    _t(context, 'Cancel Payment Request', 'Annuler la demande de paiement', 'إلغاء طلب الدفع'),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2.5),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _amber.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.hourglass_empty_rounded, color: _amber, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          _t(context, 'Payment Under Review', 'Paiement en cours de révision', 'الدفع قيد المراجعة'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _t(
            context,
            'We are verifying your transfer. Your subscription will update shortly.',
            'Nous vérifions votre virement. Votre abonnement sera mis à jour sous peu.',
            'نحن نتحقق من عملية التحويل الخاصة بك. سيتم تحديث اشتراكك قريبًا.',
          ),
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailsCard(String periodStr) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(context, 'Request Summary', 'Résumé de la demande', 'ملخص الطلب'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(_t(context, 'Reference Code', 'Code de référence', 'رمز المرجع'), widget.payment.referenceCode, isCode: true),
          const Divider(height: 24),
          _buildSummaryRow(_t(context, 'Subscription Plan', 'Plan d\'abonnement', 'باقة الاشتراك'), widget.payment.plan.name),
          const Divider(height: 24),
          _buildSummaryRow(_t(context, 'Amount paid', 'Montant payé', 'المبلغ المدفوع'), '${widget.payment.amountDzd.toStringAsFixed(0)} DZD'),
          const Divider(height: 24),
          _buildSummaryRow(_t(context, 'Coverage Period', 'Période de couverture', 'فترة التغطية'), periodStr),
          const Divider(height: 24),
          _buildSummaryRow(
            _t(context, 'Submitted At', 'Soumis le', 'تاريخ التقديم'),
            DateFormat('MMMM d, yyyy  HH:mm').format(widget.payment.periodStart),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isCode = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isCode ? _amber : const Color(0xFF374151),
              fontFamily: isCode ? 'Courier' : null,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(context, 'What Happens Next?', 'Que se passe-t-il ensuite ?', 'ماذا يحدث بعد ذلك؟'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            '1',
            _t(
              context,
              'Tawfir admins review your transfer/receipt confirmation.',
              'Les administrateurs de Tawfir examinent la confirmation de votre virement/reçu.',
              'يقوم مسؤولو Tawfir بمراجعة تأكيد التحويل/الإيصال الخاص بك.',
            ),
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            '2',
            _t(
              context,
              'Verification is typically completed within 2 to 4 hours.',
              'La vérification est généralement effectuée sous 2 à 4 heures.',
              'عادة ما تكتمل عملية التحقق في غضون ساعتين إلى 4 ساعات.',
            ),
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            '3',
            _t(
              context,
              'You will receive a push notification as soon as activation is complete.',
              'Vous recevrez une notification push dès que la mise en œuvre sera terminée.',
              'ستتلقى إشعارًا بمجرد اكتمال تفعيل الاشتراك.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(number, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
