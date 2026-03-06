import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/merchant_pending.dart';
import 'package:anti_food_waste_app/shared/widgets/upload_card.dart';

class CharityDocumentsScreen extends StatefulWidget {
  const CharityDocumentsScreen({super.key});

  @override
  State<CharityDocumentsScreen> createState() => _CharityDocumentsScreenState();
}

class _CharityDocumentsScreenState extends State<CharityDocumentsScreen> {
  String? _registrationDocName;
  String? _addressProofName;

  void _handleSubmit() {
    // Navigate to the final success/pending screen (could reuse MerchantPendingScreen or create a generic one)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MerchantPendingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const Color(0xFFFFF8E1).withOpacity(0.5)],
          ),
        ),
        child: Stack(
          children: [
            // Algerian colors accent
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Row(
                children: [
                  Expanded(child: Container(color: AppTheme.primary)),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: AppTheme.accent)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      // Header
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            "📄",
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.one_more_step,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.verify_org,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.mutedForeground,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Document Upload Cards
                      UploadCard(
                        title: l10n.official_registration,
                        fileName: _registrationDocName,
                        onUpload: () => setState(() =>
                            _registrationDocName = "registration_doc.pdf"),
                        onRemove: () =>
                            setState(() => _registrationDocName = null),
                      ),

                      const SizedBox(height: 24),

                      UploadCard(
                        title: l10n.proof_address,
                        fileName: _addressProofName,
                        onUpload: () => setState(
                            () => _addressProofName = "address_proof.jpg"),
                        onRemove: () =>
                            setState(() => _addressProofName = null),
                      ),

                      const SizedBox(height: 32),

                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Text("ℹ️", style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.review_time_short,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registrationDocName != null
                              ? _handleSubmit
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[200],
                          ),
                          child: Text(
                            l10n.submit_review,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Skip Option
                      TextButton(
                        onPressed: _handleSubmit,
                        child: Text(
                          l10n.upload_later,
                          style: const TextStyle(
                            color: AppTheme.mutedForeground,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
