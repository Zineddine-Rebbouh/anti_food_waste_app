import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/auth/data/models/auth_models.dart';
import 'package:anti_food_waste_app/features/auth/domain/models/user_role.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_state.dart';
import 'package:anti_food_waste_app/features/auth/presentation/screens/email_verification.dart';
import 'package:anti_food_waste_app/features/auth/presentation/widgets/role_selection_overlay.dart';
import 'package:anti_food_waste_app/features/auth/presentation/widgets/consumer_sign_up_form.dart';
import 'package:anti_food_waste_app/features/auth/presentation/widgets/merchant_sign_up_form.dart';
import 'package:anti_food_waste_app/features/auth/presentation/widgets/charity_sign_up_form.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/merchant_pending.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/charity_document_comfirmation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  UserRole? _selectedRole;
  bool _showRoleSelection = true;
  bool _agreedToTerms = false;
  bool _sendUpdates = false;

  // Controllers for general fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controllers for merchant fields
  final _businessNameController = TextEditingController();
  String _businessType = 'bakery';
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _merchantContactNameController = TextEditingController();

  // Controllers for charity fields
  final _orgNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _orgAddressController = TextEditingController();
  final _charityContactPersonController = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _merchantContactNameController.dispose();
    _orgNameController.dispose();
    _regNumberController.dispose();
    _orgAddressController.dispose();
    _charityContactPersonController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      _showRoleSelection = false;
    });
  }

  void _handleSubmit() {
    final role = _selectedRole;
    if (role == null) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Build role-specific phone and profile_data
    final String phone;
    Map<String, dynamic>? profileData;

    switch (role) {
      case UserRole.merchant:
        phone = _businessPhoneController.text.trim();
        profileData = {
          'business_name': _businessNameController.text.trim(),
          'business_type': _businessType,
        };
      case UserRole.charity:
        phone = _phoneController.text.trim();
        profileData = {
          'organization_name': _orgNameController.text.trim(),
        };
      case UserRole.consumer:
        phone = _phoneController.text.trim();
        profileData = null;
    }

    context.read<AuthCubit>().register(
          RegisterRequest(
            email: email,
            phone: phone,
            password: password,
            passwordConfirm: password,
            userType: role.name, // "consumer" | "merchant" | "charity"
            profileData: profileData,
          ),
        );
  }

  void _onAuthenticated(String userType) {
    switch (userType) {
      case 'merchant':
        // Merchant needs admin approval — show pending screen.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MerchantPendingScreen()),
          (_) => false,
        );
      case 'charity':
        // Charity must upload legal documents first, then pending screen.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CharityDocumentsScreen()),
          (_) => false,
        );
      default:
        // Consumer — must verify email before accessing the app.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
          (_) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _onAuthenticated(state.userType);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.destructive,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back,
                color: AppTheme.foreground),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _selectedRole == UserRole.merchant
                ? l10n.business_signup
                : _selectedRole == UserRole.charity
                    ? l10n.charity_signup
                    : l10n.create_account,
            style: const TextStyle(color: AppTheme.foreground, fontSize: 20),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, Colors.white, AppTheme.accent],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            if (_selectedRole != null)
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedRole == UserRole.consumer)
                        ConsumerSignUpForm(
                          fullNameController: _fullNameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          agreedToTerms: _agreedToTerms,
                          sendUpdates: _sendUpdates,
                          onTermsChanged: (val) =>
                              setState(() => _agreedToTerms = val),
                          onUpdatesChanged: (val) =>
                              setState(() => _sendUpdates = val),
                        ),
                      if (_selectedRole == UserRole.merchant)
                        MerchantSignUpForm(
                          businessNameController: _businessNameController,
                          businessType: _businessType,
                          businessAddressController: _businessAddressController,
                          businessPhoneController: _businessPhoneController,
                          contactNameController: _merchantContactNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          agreedToTerms: _agreedToTerms,
                          onBusinessTypeChanged: (val) =>
                              setState(() => _businessType = val),
                          onTermsChanged: (val) =>
                              setState(() => _agreedToTerms = val),
                        ),
                      if (_selectedRole == UserRole.charity)
                        CharitySignUpForm(
                          orgNameController: _orgNameController,
                          regNumberController: _regNumberController,
                          orgAddressController: _orgAddressController,
                          contactPersonController:
                              _charityContactPersonController,
                          positionController: _positionController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          agreedToTerms: _agreedToTerms,
                          onTermsChanged: (val) =>
                              setState(() => _agreedToTerms = val),
                        ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(l10n),
                      const SizedBox(height: 16),
                      _buildLoginLink(l10n),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            if (_showRoleSelection)
              RoleSelectionOverlay(
                onRoleSelected: _selectRole,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return ElevatedButton(
          onPressed: (_agreedToTerms && !isLoading) ? _handleSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _selectedRole == UserRole.merchant
                      ? l10n.submit_approval
                      : _selectedRole == UserRole.charity
                          ? l10n.submit_verification
                          : l10n.create_account,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
        );
      },
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.already_have_account,
            style: const TextStyle(
                color: AppTheme.mutedForeground, fontSize: 14)),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.login),
          child: Text(l10n.login,
              style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
