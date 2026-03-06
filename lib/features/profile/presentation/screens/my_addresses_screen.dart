import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class UserAddress {
  final String id;
  final String label;
  final String street;
  final String city;
  final String wilaya;
  final String postalCode;
  bool isDefault;

  UserAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.wilaya,
    required this.postalCode,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $wilaya $postalCode';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  List<UserAddress> _addresses = [
    UserAddress(
      id: '1',
      label: 'Home',
      street: '12 Rue des Oliviers',
      city: 'Bab Ezzouar',
      wilaya: 'Alger',
      postalCode: '16111',
      isDefault: true,
    ),
    UserAddress(
      id: '2',
      label: 'Work',
      street: 'Tour A, Cité El Djamaâ',
      city: 'El Mohammadia',
      wilaya: 'Alger',
      postalCode: '16301',
      isDefault: false,
    ),
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  String _labelDisplay(String label, AppLocalizations l10n) {
    switch (label.toLowerCase()) {
      case 'home':
        return l10n.home_label;
      case 'work':
        return l10n.work_label;
      default:
        return l10n.other_label;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _setDefaultAddress(String id) {
    setState(() {
      for (final a in _addresses) {
        a.isDefault = a.id == id;
      }
    });
  }

  void _deleteAddress(String id) {
    setState(() => _addresses.removeWhere((a) => a.id == id));
  }

  void _showAddressSheet(UserAddress? existing) {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final streetCtrl =
        TextEditingController(text: existing?.street ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final wilayaCtrl =
        TextEditingController(text: existing?.wilaya ?? '');
    final postalCtrl =
        TextEditingController(text: existing?.postalCode ?? '');
    String selectedLabel = existing?.label ?? 'Home';
    bool isDefault = existing?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sheet handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        existing == null
                            ? l10n.add_address
                            : l10n.edit_address,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Label selector chips
                      Text(
                        l10n.address_label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Home', 'Work', 'Other'].map((lbl) {
                          final selected = selectedLabel == lbl;
                          final display = lbl == 'Home'
                              ? l10n.home_label
                              : lbl == 'Work'
                                  ? l10n.work_label
                                  : l10n.other_label;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(display),
                              selected: selected,
                              onSelected: (_) => setSheetState(
                                  () => selectedLabel = lbl),
                              selectedColor:
                                  AppTheme.primary.withOpacity(0.15),
                              checkmarkColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.mutedForeground,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: AppTheme.inputBackground,
                              side: BorderSide.none,
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Street
                      TextFormField(
                        controller: streetCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.street_address,
                          filled: true,
                          fillColor: AppTheme.inputBackground,
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
                            borderSide: const BorderSide(
                                color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? l10n.street_address
                                : null,
                      ),
                      const SizedBox(height: 12),

                      // City
                      TextFormField(
                        controller: cityCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.city_town,
                          filled: true,
                          fillColor: AppTheme.inputBackground,
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
                            borderSide: const BorderSide(
                                color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? l10n.city_town
                                : null,
                      ),
                      const SizedBox(height: 12),

                      // Wilaya
                      TextFormField(
                        controller: wilayaCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.wilaya_label,
                          filled: true,
                          fillColor: AppTheme.inputBackground,
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
                            borderSide: const BorderSide(
                                color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? l10n.wilaya_label
                                : null,
                      ),
                      const SizedBox(height: 12),

                      // Postal code
                      TextFormField(
                        controller: postalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.postal_code,
                          filled: true,
                          fillColor: AppTheme.inputBackground,
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
                            borderSide: const BorderSide(
                                color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? l10n.postal_code
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Set as default switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.set_as_default_address,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Switch(
                            value: isDefault,
                            activeColor: AppTheme.primary,
                            onChanged: (v) =>
                                setSheetState(() => isDefault = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                if (existing != null) {
                                  // Edit existing
                                  if (isDefault) {
                                    for (final a in _addresses) {
                                      if (a.id != existing.id) {
                                        a.isDefault = false;
                                      }
                                    }
                                  }
                                  final idx = _addresses.indexWhere(
                                      (a) => a.id == existing.id);
                                  if (idx != -1) {
                                    _addresses[idx] = UserAddress(
                                      id: existing.id,
                                      label: selectedLabel,
                                      street: streetCtrl.text.trim(),
                                      city: cityCtrl.text.trim(),
                                      wilaya: wilayaCtrl.text.trim(),
                                      postalCode: postalCtrl.text.trim(),
                                      isDefault: isDefault,
                                    );
                                  }
                                } else {
                                  // Add new
                                  if (isDefault) {
                                    for (final a in _addresses) {
                                      a.isDefault = false;
                                    }
                                  }
                                  _addresses.add(UserAddress(
                                    id: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    label: selectedLabel,
                                    street: streetCtrl.text.trim(),
                                    city: cityCtrl.text.trim(),
                                    wilaya: wilayaCtrl.text.trim(),
                                    postalCode: postalCtrl.text.trim(),
                                    isDefault: isDefault,
                                  ));
                                }
                              });
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(existing == null
                                      ? l10n.add_address
                                      : l10n.edit_address),
                                  backgroundColor: AppTheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                          child: Text(
                            l10n.save_address,
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
            );
          },
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.my_addresses,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.black),
            onPressed: () => _showAddressSheet(null),
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? _buildEmptyState(l10n)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 80),
                  duration: const Duration(milliseconds: 400),
                  child: _buildAddressTile(context, address, l10n),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressSheet(null),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.add_address),
        elevation: 2,
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_outlined,
              size: 64, color: AppTheme.mutedForeground),
          const SizedBox(height: 16),
          Text(
            l10n.no_addresses,
            style: const TextStyle(
              color: AppTheme.mutedForeground,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddressSheet(null),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.add_address),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(
      BuildContext context, UserAddress address, AppLocalizations l10n) {
    return Dismissible(
      key: Key(address.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              l10n.delete_address,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(l10n.delete_address_confirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel,
                    style: const TextStyle(
                        color: AppTheme.mutedForeground)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  l10n.delete_address,
                  style: const TextStyle(color: AppTheme.accent),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteAddress(address.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + label column
                Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _labelIcon(address.label),
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labelDisplay(address.label, l10n),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Address content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _labelDisplay(address.label, l10n),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                l10n.default_address_label,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: const TextStyle(
                          color: AppTheme.mutedForeground,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Popup menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppTheme.mutedForeground, size: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'default') {
                      _setDefaultAddress(address.id);
                    } else if (value == 'edit') {
                      _showAddressSheet(address);
                    } else if (value == 'delete') {
                      showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text(l10n.delete_address,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          content:
                              Text(l10n.delete_address_confirm),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(ctx).pop(false),
                              child: Text(l10n.cancel,
                                  style: const TextStyle(
                                      color: AppTheme.mutedForeground)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(true);
                                _deleteAddress(address.id);
                              },
                              child: Text(l10n.delete_address,
                                  style: const TextStyle(
                                      color: AppTheme.accent)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    if (!address.isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 18, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(l10n.set_as_default_address),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 18,
                              color: AppTheme.mutedForeground),
                          const SizedBox(width: 8),
                          Text(l10n.edit_address),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline,
                              size: 18, color: AppTheme.accent),
                          const SizedBox(width: 8),
                          Text(
                            l10n.delete_address,
                            style:
                                const TextStyle(color: AppTheme.accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
