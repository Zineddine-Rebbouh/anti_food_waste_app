import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/app_user.dart';
import 'package:anti_food_waste_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/impact_dashboard_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/my_addresses_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/about_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/terms_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:anti_food_waste_app/features/help/presentation/screens/help_screen.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_panel.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_bell_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Infrastructure ──────────────────────────────────────────────────────
  late final ProfileCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  XFile? _avatarFile;

  static const double _expandedHeight = 200.0;
  static const Color _darkGreen = Color(0xFF1B5E38);

  // ── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit();
    _scrollController.addListener(_onScroll);
    _cubit.loadProfile();
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = _expandedHeight - kToolbarHeight;
    final collapsed = _scrollController.hasClients &&
        _scrollController.offset >= threshold;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  Future<void> _pickImage(BuildContext context) async {
    // Capture context-dependent objects before the async gap.
    final messenger = ScaffoldMessenger.of(context);
    final photoChangedMsg = AppLocalizations.of(context)!.photo_changed;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      setState(() => _avatarFile = file);
      _cubit.updateAvatar(file.path);
      messenger.showSnackBar(
        SnackBar(
          content: Text(photoChangedMsg),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showNotificationPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, __) => const NotificationPanel(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.logout_confirm_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.logout_confirm_message),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppTheme.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppRouter.exitToRoleSelector(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context, state, l10n),
                SliverToBoxAdapter(
                  child: _buildContent(context, state, l10n),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── SliverAppBar ─────────────────────────────────────────────────────────
  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    ProfileState state,
    AppLocalizations l10n,
  ) {
    final foreground =
        _isCollapsed ? AppTheme.foreground : Colors.white;

    return SliverAppBar(
      expandedHeight: _expandedHeight,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _isCollapsed ? Colors.white : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: foreground,
      title: AnimatedOpacity(
        opacity: _isCollapsed ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          l10n.profile,
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.bell, color: foreground),
          onPressed: () => _showNotificationPanel(context),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildHeaderBackground(context, state, l10n),
      ),
    );
  }

  // ── Expanded Header ──────────────────────────────────────────────────────
  Widget _buildHeaderBackground(
    BuildContext context,
    ProfileState state,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, _darkGreen],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: state is ProfileLoaded
            ? _buildHeaderContent(context, state.user, l10n)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHeaderContent(
    BuildContext context,
    AppUser user,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ──────────────────────────────────────────────────
              Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: _avatarFile != null
                        ? ClipOval(
                            child: Image.file(
                              File(_avatarFile!.path),
                              fit: BoxFit.cover,
                              width: 84,
                              height: 84,
                            ),
                          )
                        : user.avatarUrl.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.avatarUrl,
                                  fit: BoxFit.cover,
                                  width: 84,
                                  height: 84,
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                  ),
                  // Camera badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // ── Name + email + badges ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Eco-Score pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🌱 ${l10n.eco_score}: ${user.ecoScore.toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Level chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            '🥈 ${user.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Content router ────────────────────────────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    ProfileState state,
    AppLocalizations l10n,
  ) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return _buildShimmer();
    }
    if (state is ProfileError) {
      return _buildError(context, state.message, l10n);
    }
    if (state is ProfileLoaded) {
      return _buildLoadedContent(context, state.user, l10n);
    }
    return const SizedBox.shrink();
  }

  // ── Loaded content ────────────────────────────────────────────────────────
  Widget _buildLoadedContent(
    BuildContext context,
    AppUser user,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats row ──────────────────────────────────────────────────
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: _buildStatsCard(user, l10n),
          ),
          const SizedBox(height: 24),

          // ── Account section ────────────────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 80),
            duration: const Duration(milliseconds: 400),
            child: _buildSection(
              title: l10n.account_section,
              child: _buildAccountCard(context, l10n),
            ),
          ),
          const SizedBox(height: 20),

          // ── Preferences section ────────────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 160),
            duration: const Duration(milliseconds: 400),
            child: _buildSection(
              title: l10n.preferences_section,
              child: _buildPreferencesCard(context, l10n),
            ),
          ),
          const SizedBox(height: 20),

          // ── Information section ────────────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 240),
            duration: const Duration(milliseconds: 400),
            child: _buildSection(
              title: l10n.information_section,
              child: _buildInformationCard(context, l10n),
            ),
          ),
          const SizedBox(height: 28),

          // ── Logout ─────────────────────────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 320),
            duration: const Duration(milliseconds: 400),
            child: _buildLogoutButton(context, l10n),
          ),
          const SizedBox(height: 24),

          // ── Made in Algeria ────────────────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 400),
            child: Center(
              child: Text(
                l10n.made_in_algeria,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Stats Card ────────────────────────────────────────────────────────────
  Widget _buildStatsCard(AppUser user, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.bag,
                count: user.ordersCount.toString(),
                label: l10n.orders_label,
                color: AppTheme.info,
              ),
            ),
            Container(
              width: 1,
              height: 52,
              color: Colors.grey.shade100,
            ),
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.leaf_arrow_circlepath,
                count: user.mealsSaved.toString(),
                label: l10n.rescues_label,
                color: AppTheme.primary,
              ),
            ),
            Container(
              width: 1,
              height: 52,
              color: Colors.grey.shade100,
            ),
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.cloud,
                count: '${user.co2Reduced}kg',
                label: l10n.co2_avoided,
                color: const Color(0xFF7B61FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.mutedForeground,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.mutedForeground,
              letterSpacing: 0.8,
            ),
          ),
        ),
        child,
      ],
    );
  }

  // ── Account section card ──────────────────────────────────────────────────
  Widget _buildAccountCard(BuildContext context, AppLocalizations l10n) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return _menuCard(children: [
      _menuTile(
        icon: CupertinoIcons.person_crop_circle,
        iconColor: AppTheme.primary,
        title: l10n.edit_profile,
        isRTL: isRTL,
        isFirst: true,
        onTap: () {
          final cubit = context.read<ProfileCubit>();
          final loaded = cubit.state;
          if (loaded is ProfileLoaded) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: EditProfileScreen(user: loaded.user),
                ),
              ),
            );
          }
        },
      ),
      _divider(),
      _menuTile(
        icon: Icons.bar_chart_rounded,
        iconColor: AppTheme.primary,
        title: l10n.impact_dashboard,
        isRTL: isRTL,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const ImpactDashboardScreen(),
          ),
        ),
      ),
      _divider(),
      _menuTile(
        icon: Icons.location_on_outlined,
        iconColor: Colors.blue,
        title: l10n.my_addresses,
        isRTL: isRTL,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const MyAddressesScreen(),
          ),
        ),
      ),
      _divider(),
      _menuTile(
        icon: Icons.credit_card_rounded,
        iconColor: Colors.orange,
        title: l10n.payment_methods,
        isRTL: isRTL,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const PaymentMethodsScreen(),
          ),
        ),
      ),
      _divider(),
      _menuTile(
        icon: Icons.lock_outline_rounded,
        iconColor: Colors.purple,
        title: l10n.change_password,
        isRTL: isRTL,
        isLast: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const ChangePasswordScreen(),
          ),
        ),
      ),
    ]);
  }

  // ── Preferences section card ──────────────────────────────────────────────
  Widget _buildPreferencesCard(BuildContext context, AppLocalizations l10n) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return _menuCard(children: [
      _menuTile(
        icon: Icons.settings_outlined,
        iconColor: const Color(0xFF5C6BC0), // indigo
        title: l10n.settings,
        isRTL: isRTL,
        isFirst: true,
        isLast: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
        ),
      ),
    ]);
  }

  // ── Information section card ──────────────────────────────────────────────
  Widget _buildInformationCard(BuildContext context, AppLocalizations l10n) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return _menuCard(children: [
      _menuTile(
        icon: Icons.info_outline_rounded,
        iconColor: AppTheme.primary,
        title: l10n.about_app,
        isRTL: isRTL,
        isFirst: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
        ),
      ),
      _divider(),
      _menuTile(
        icon: Icons.description_outlined,
        iconColor: AppTheme.mutedForeground,
        title: l10n.terms_service,
        isRTL: isRTL,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
        ),
      ),
      _divider(),
      _menuTile(
        icon: Icons.privacy_tip_outlined,
        iconColor: AppTheme.mutedForeground,
        title: l10n.privacy_policy,
        isRTL: isRTL,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const PrivacyPolicyScreen(),
          ),
        ),
      ),
      _divider(),
      _menuTile(
        icon: Icons.help_outline_rounded,
        iconColor: Colors.blue,
        title: l10n.help_support,
        isRTL: isRTL,
        isLast: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const HelpCenterScreen()),
        ),
      ),
    ]);
  }

  // ── Shared card / tile builders ───────────────────────────────────────────
  Widget _menuCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isRTL,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              isRTL ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.only(left: 68),
        child: Divider(height: 1, color: Colors.grey.shade100),
      );

  // ── Logout button ─────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
          color: AppTheme.accent,
        ),
        label: Text(
          l10n.sign_out,
          style: const TextStyle(
            color: AppTheme.accent,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: AppTheme.accent.withOpacity(0.06),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── Shimmer (loading state) ───────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats card placeholder
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            // Three section placeholders
            ...[200.0, 110.0, 220.0].map((height) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildError(
    BuildContext context,
    String message,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.error_outline_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _cubit.loadProfile,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

