import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Private data model
// ─────────────────────────────────────────────────────────────────────────────

class _Card {
  final String id;
  String last4;
  String brand; // 'visa' | 'mastercard' | 'cib' | 'dahabia'
  String expiry; // 'MM/YY'
  bool isDefault;

  _Card({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiry,
    required this.isDefault,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand meta-data helper (private to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _BrandInfo {
  final String emoji;
  final String name;
  final Color color;

  const _BrandInfo({
    required this.emoji,
    required this.name,
    required this.color,
  });
}

const Map<String, _BrandInfo> _kBrands = {
  'visa': _BrandInfo(
    emoji: '💳',
    name: 'Visa',
    color: Color(0xFF1A1F71),
  ),
  'mastercard': _BrandInfo(
    emoji: '💳',
    name: 'Mastercard',
    color: Color(0xFFEB001B),
  ),
  'cib': _BrandInfo(
    emoji: '💳',
    name: 'CIB',
    color: Color(0xFF2D8659),
  ),
  'dahabia': _BrandInfo(
    emoji: '💳',
    name: 'Dahabia',
    color: Color(0xFFFF6D00),
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // ── Mock initial data ──────────────────────────────────────────────────────

  final List<_Card> _cards = [
    _Card(
      id: 'card_1',
      last4: '4242',
      brand: 'visa',
      expiry: '12/26',
      isDefault: true,
    ),
    _Card(
      id: 'card_2',
      last4: '1234',
      brand: 'cib',
      expiry: '09/25',
      isDefault: false,
    ),
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _setDefault(String cardId) {
    setState(() {
      for (final card in _cards) {
        card.isDefault = card.id == cardId;
      }
    });
  }

  void _deleteCard(String cardId) {
    setState(() {
      _cards.removeWhere((c) => c.id == cardId);
      // If the removed card was the default, promote the first remaining card.
      if (_cards.isNotEmpty && !_cards.any((c) => c.isDefault)) {
        _cards.first.isDefault = true;
      }
    });
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade700,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.delete_card,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.delete_card_confirm,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.delete_card,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared field decoration for the add-card form ─────────────────────────

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      counterText: '',
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // ── Add-card bottom sheet ─────────────────────────────────────────────────

  void _showAddCardSheet() {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final cardNumberCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle ──────────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Text(
                  l10n.add_payment_method,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.foreground,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  'Your card details are encrypted end-to-end.',
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade100),

              // Form ─────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card number ──────────────────────────────────
                        TextFormField(
                          controller: cardNumberCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 19, // 16 digits + 3 spaces
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CardNumberFormatter(),
                          ],
                          decoration: _fieldDecoration(l10n.card_number),
                          validator: (v) {
                            if (v == null ||
                                v.replaceAll(' ', '').length < 16) {
                              return 'Enter a valid 16-digit card number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Expiry + CVV ─────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: expiryCtrl,
                                keyboardType: TextInputType.number,
                                maxLength: 5, // MM/YY
                                inputFormatters: [_ExpiryFormatter()],
                                decoration: _fieldDecoration(
                                  l10n.expiry_placeholder,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Required';
                                  }
                                  if (!RegExp(r'^\d{2}/\d{2}$')
                                      .hasMatch(v)) {
                                    return 'Use MM/YY';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: cvvCtrl,
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                obscureText: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration:
                                    _fieldDecoration(l10n.cvv),
                                validator: (v) {
                                  if (v == null || v.length < 3) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Cardholder name ──────────────────────────────
                        TextFormField(
                          controller: nameCtrl,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration:
                              _fieldDecoration(l10n.cardholder_name),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Add button ───────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final raw = cardNumberCtrl.text
                                    .replaceAll(' ', '');
                                final last4 =
                                    raw.substring(raw.length - 4);
                                final firstDigit = raw.isNotEmpty
                                    ? raw[0]
                                    : '0';
                                final brand = firstDigit == '4'
                                    ? 'visa'
                                    : firstDigit == '5'
                                        ? 'mastercard'
                                        : 'cib';

                                final newCard = _Card(
                                  id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                                  last4: last4,
                                  brand: brand,
                                  expiry: expiryCtrl.text,
                                  isDefault: _cards.isEmpty,
                                );

                                setState(() => _cards.add(newCard));
                                Navigator.of(sheetCtx).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.add,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.payment_methods,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.foreground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppTheme.primary,
            tooltip: l10n.add_payment_method,
            onPressed: _showAddCardSheet,
          ),
        ],
      ),
      body: _cards.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.credit_card_off_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.no_payment_methods,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Card list ──────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: _cards.length,
                    itemBuilder: (listCtx, index) {
                      final card = _cards[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(card.id),
                          direction:
                              DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          confirmDismiss: (_) =>
                              _confirmDelete(context, l10n),
                          onDismissed: (_) =>
                              _deleteCard(card.id),
                          child: _CardTile(
                            card: card,
                            l10n: l10n,
                            onSetDefault: () =>
                                _setDefault(card.id),
                            onDelete: () async {
                              final confirmed =
                                  await _confirmDelete(
                                context,
                                l10n,
                              );
                              if (confirmed == true &&
                                  mounted) {
                                _deleteCard(card.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── SSL footer ─────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.secured_by_ssl,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CardTile
// ─────────────────────────────────────────────────────────────────────────────

class _CardTile extends StatelessWidget {
  final _Card card;
  final AppLocalizations l10n;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.l10n,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final info = _kBrands[card.brand] ?? _kBrands['cib']!;

    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand icon circle ──────────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  info.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Brand name + masked number ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '•••• ${card.last4}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Expiry ─────────────────────────────────────────────────
            Text(
              card.expiry,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 4),

            // Default badge + popup menu ─────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (card.isDefault) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      l10n.default_card_label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (_) => [
                    if (!card.isDefault)
                      PopupMenuItem<String>(
                        value: 'default',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.set_as_default,
                              style:
                                  const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.delete_card,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'default') onSetDefault();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input formatters
// ─────────────────────────────────────────────────────────────────────────────

/// Formats a digit-only string into groups of 4: "1234 5678 9012 3456".
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // newValue contains only digits (FilteringTextInputFormatter ran first).
    final digits = newValue.text;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats raw input into "MM/YY", stripping any non-digit characters first.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Clamp to 4 digits (MMYY).
    final limited =
        digits.length > 4 ? digits.substring(0, 4) : digits;

    final formatted = limited.length > 2
        ? '${limited.substring(0, 2)}/${limited.substring(2)}'
        : limited;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
