import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/subscription_pending_screen.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter/services.dart';

/// Page 2: Payment instructions and receipt upload.
class PaymentInstructionsScreen extends StatefulWidget {
  final SubscriptionPlan plan;

  const PaymentInstructionsScreen({super.key, required this.plan});

  @override
  State<PaymentInstructionsScreen> createState() => _PaymentInstructionsScreenState();
}

class _PaymentInstructionsScreenState extends State<PaymentInstructionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  late DateTime _endDate;
  String _paymentMethod = 'bank_transfer';
  XFile? _receiptImage;
  bool _isSubmitting = false;

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

  @override
  void initState() {
    super.initState();
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
              primary: _green,
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

  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null) {
        setState(() => _receiptImage = picked);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t(context, 'Select Proof of Payment', 'Sélectionner la preuve de paiement', 'اختر إثبات الدفع'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: _t(context, 'Camera', 'Appareil photo', 'الكاميرا'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickReceipt(ImageSource.camera);
                    },
                  ),
                  _buildSourceOption(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: _t(context, 'Gallery', 'Galerie', 'المعرض'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickReceipt(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: _green, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t(context,
              'Please upload a photo of your payment receipt.',
              'Veuillez télécharger une photo de votre reçu de paiement.',
              'يرجى تحميل صورة لإيصال الدفع.')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cubit = context.read<BillingCubit>();

      // 1. Upload receipt image
      String receiptImageUrl = '';
      if (_receiptImage != null) {
        receiptImageUrl = await cubit.uploadReceipt(_receiptImage!.path);
      }

      // 2. Submit payment request
      final payment = await cubit.requestUpgrade(
        planId: widget.plan.id,
        periodStart: _startDate,
        periodEnd: _endDate,
        paymentMethod: _paymentMethod,
        referenceNumber: _referenceController.text.trim(),
        receiptImageUrl: receiptImageUrl,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: SubscriptionPendingScreen(payment: payment),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(_t(context, 'Request Failed', 'Échec de la demande', 'فشل الطلب')),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_t(context, 'OK', 'OK', 'حسنًا'), style: const TextStyle(color: _green)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _t(context, 'Payment Details', 'Détails du paiement', 'تفاصيل الدفع'),
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: _green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildInstructionsCard(),
                const SizedBox(height: 24),
                _buildUploadSection(),
                const SizedBox(height: 24),
                _buildInputsCard(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _t(context, "I've Made This Payment", "J'ai effectué ce paiement", "لقد قمت بإجراء هذا الدفع"),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: Text(
                    _t(context, "I'll do this later", "Je le ferai plus tard", "سأفعل هذا لاحقًا"),
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: _green, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.plan.monthlyPriceDzd.toStringAsFixed(0)} DZD / ${_t(context, 'month', 'mois', 'شهر')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
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
            _t(context, 'How to Pay', 'Comment payer', 'طريقة الدفع'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            number: '1',
            text: _t(
              context,
              'Transfer or deposit standard amount to the Tawfir CCP or Bank account.',
              'Transférez ou déposez le montant sur le compte CCP ou bancaire de Tawfir.',
              'قم بتحويل أو إيداع المبلغ في حساب CCP أو الحساب البنكي لـ Tawfir.',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountDetail(
                  _t(context, 'Account Name', 'Nom du compte', 'اسم الحساب'),
                  'EURL Tawfir SaveFood',
                ),
                const Divider(height: 20),
                _buildAccountDetail(
                  _t(context, 'CCP Account Number', 'Numéro de compte CCP', 'رقم حساب CCP'),
                  '0021345678 Key 89',
                  copyable: true,
                ),
                const Divider(height: 20),
                _buildAccountDetail(
                  _t(context, 'RIP (Bank)', 'RIP (Banque)', 'رقم الحساب البنكي (RIP)'),
                  '00799999002134567889',
                  copyable: true,
                ),
                const Divider(height: 20),
                _buildAccountDetail(
                  _t(context, 'Amount Owed', 'Montant dû', 'المبلغ المطلوب'),
                  '${widget.plan.monthlyPriceDzd.toStringAsFixed(0)} DZD',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            number: '2',
            text: _t(
              context,
              'Keep the physical or digital receipt slip and take a clear photo of it.',
              'Conservez le reçu physique ou numérique et prenez-en une photo claire.',
              'احتفظ بإيصال الدفع الورقي أو الرقمي والتقط صورة واضحة له.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetail(String label, String value, {bool copyable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          ],
        ),
        if (copyable)
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: _green, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value.split(' ').first));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_t(context, 'Copied to clipboard', 'Copié dans le presse-papiers', 'تم النسخ للحافظة'))),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInstructionStep({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
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
            _t(context, 'Upload Payment Receipt', 'Télécharger le reçu de paiement', 'تحميل إيصال الدفع'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          Text(
            _t(context, 'JPEG, PNG or WebP image formats', 'Formats d\'image JPEG, PNG ou WebP', 'صيغ الصور JPEG أو PNG أو WebP'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (_receiptImage != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_receiptImage!.path),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => setState(() => _receiptImage = null),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: _showImageSourceSelector,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: Colors.grey.shade400, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      _t(context, 'Tap to snap or upload photo', 'Appuyez pour prendre ou charger une photo', 'اضغط لالتقاط أو تحميل صورة'),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputsCard() {
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
            _t(context, 'Transaction Info', 'Info transaction', 'معلومات المعاملة'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
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
                        _t(context, 'Desired Start Date', 'Date de début souhaitée', 'تاريخ البدء المطلوب'),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_startDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const Icon(Icons.calendar_today_rounded, color: _green, size: 20),
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
                      _t(context, 'End Date (Auto-calculated, 30 days)', 'Date de fin (calculée automatiquement, 30 jours)', 'تاريخ الانتهاء (محسوب تلقائيًا، 30 يومًا)'),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
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
              labelText: _t(context, 'Payment Method', 'Méthode de paiement', 'طريقة الدفع'),
              labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem(value: 'bank_transfer', child: Text(_t(context, 'Bank / CCP Transfer', 'Virement bancaire / CCP', 'تحويل بنكي / CCP'))),
              DropdownMenuItem(value: 'cash', child: Text(_t(context, 'Cash Payment', 'Paiement en espèces', 'الدفع نقدًا'))),
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
              labelText: _t(context, 'Transfer Reference / Receipt Number', 'Référence du virement / numéro du reçu', 'مرجع التحويل / رقم الإيصال'),
              labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
              hintText: _t(context, 'Enter transaction ID or receipt slip #', 'Saisissez l\'ID de transaction ou le numéro du reçu', 'أدخل معرّف المعاملة أو رقم الإيصال'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return _t(context, 'Please enter transaction/receipt reference', 'Veuillez saisir une référence', 'يرجى إدخال مرجع المعاملة/الإيصال');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: _t(context, 'Notes (Optional)', 'Notes (facultatif)', 'ملاحظات (اختياري)'),
              labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
