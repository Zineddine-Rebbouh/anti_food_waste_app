import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
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
import 'package:anti_food_waste_app/features/profile/presentation/screens/about_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/eco_score_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/cubits/eco_score_cubit.dart';
import 'package:anti_food_waste_app/features/help/presentation/screens/help_screen.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_panel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  XFile? _avatarFile;

  static const double _headerHeight = 310.0;

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
    const threshold = _headerHeight - kToolbarHeight - 60;
    final collapsed = _scrollController.hasClients && _scrollController.offset >= threshold;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    HapticFeedback.mediumImpact();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showNotificationPanel(BuildContext context) {
    HapticFeedback.lightImpact();
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
    HapticFeedback.heavyImpact();
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.logout_confirm_title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.logout_confirm_message,
                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: const Color(0xFFF3F4F6),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthCubit>().logout();
                        AppRouter.exitToLogin(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.confirm,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
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

  Widget _buildSliverAppBar(BuildContext context, ProfileState state, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: _headerHeight,
      pinned: true,
      elevation: 0,
      backgroundColor: _isCollapsed ? AppTheme.primary : Colors.transparent,
      centerTitle: true,
      title: AnimatedOpacity(
        opacity: _isCollapsed ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          l10n.profile,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.bell_fill, color: Colors.white, size: 22),
          onPressed: () => _showNotificationPanel(context),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: ClipPath(
          clipper: _HeaderClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, Color(0xFF0D2119)],
              ),
            ),
            child: Stack(
              children: [
                // Decorative Blurred Circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle),
                  ),
                ),
                // User Info
                if (state is ProfileLoaded)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildAvatar(state.user),
                        const SizedBox(height: 16),
                        FadeInDown(
                          duration: const Duration(milliseconds: 400),
                          child: Column(
                            children: [
                              Text(
                                state.user.name,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.eco_rounded, color: Color(0xFF10B981), size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${l10n.eco_score}: ${state.user.ecoScore.toInt()}',
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      state.user.ecoTier.toUpperCase(),
                                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AppUser user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow Ring
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
            ],
          ),
        ),
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          ),
          child: Hero(
            tag: 'profile-avatar-main',
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: _avatarFile != null
                  ? ClipOval(child: Image.file(File(_avatarFile!.path), fit: BoxFit.cover, width: 92, height: 92))
                  : user.avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.avatarUrl,
                            fit: BoxFit.cover,
                            width: 92,
                            height: 92,
                            placeholder: (_, __) => const CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
        ),
        // Edit Button
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: () => _pickImage(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: const Icon(CupertinoIcons.camera_fill, size: 16, color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ProfileState state, AppLocalizations l10n) {
    if (state is ProfileLoading || state is ProfileInitial) return _buildShimmer();
    if (state is ProfileError) return _buildError(state.message, l10n);
    if (state is ProfileLoaded) {
      return Transform.translate(
        offset: const Offset(0, -40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // 1. Floating Impact Card
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: _buildFloatingImpactCard(state.user, l10n),
              ),
              const SizedBox(height: 32),

              // 2. Sections
              _buildModernSection(
                title: l10n.account_section,
                items: [
                  _MenuData(
                    icon: CupertinoIcons.person_circle_fill,
                    title: l10n.edit_profile,
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: EditProfileScreen(user: state.user),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuData(
                    icon: Icons.auto_graph_rounded,
                    title: l10n.impact_dashboard,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const ImpactDashboardScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuData(
                    icon: Icons.eco_rounded,
                    title: l10n.eco_score,
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: cubit),
                              BlocProvider(create: (_) => EcoScoreCubit()),
                            ],
                            child: EcoScoreScreen(user: state.user),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuData(
                    icon: CupertinoIcons.location_solid,
                    title: l10n.my_addresses,
                    color: const Color(0xFFEC4899),
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const MyAddressesScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuData(
                    icon: CupertinoIcons.creditcard_fill,
                    title: l10n.payment_methods,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const PaymentMethodsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuData(
                    icon: CupertinoIcons.lock_shield_fill,
                    title: l10n.change_password,
                    color: const Color(0xFF6B7280),
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const ChangePasswordScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildModernSection(
                title: l10n.information_section,
                items: [
                  _MenuData(
                    icon: CupertinoIcons.question_circle_fill,
                    title: l10n.help_support,
                    color: const Color(0xFF06B6D4),
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const HelpScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuData(
                    icon: CupertinoIcons.info_circle_fill,
                    title: l10n.about_app,
                    color: AppTheme.primary,
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const AboutScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),
              FadeIn(
                delay: const Duration(milliseconds: 800),
                child: _buildLogoutButton(l10n),
              ),
              const SizedBox(height: 20),
              Text(l10n.made_in_algeria, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 60),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFloatingImpactCard(AppUser user, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.your_impact, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  const SizedBox(height: 2),
                  Text(user.ecoTier.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1.2)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(user.ordersCount.toString(), l10n.orders_label, CupertinoIcons.bag_fill, const Color(0xFF3B82F6)),
              _buildStatDivider(),
              _buildStatItem(user.mealsSaved.toString(), l10n.rescues_label, Icons.eco_rounded, const Color(0xFF10B981)),
              _buildStatDivider(),
              _buildStatItem("${user.co2Reduced}kg", "CO2", Icons.cloud_done_rounded, const Color(0xFF7C3AED)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade100);
  }

  Widget _buildModernSection({required String title, required List<_MenuData> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade50),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildListTile(item),
                  if (index != items.length - 1) Divider(height: 1, color: Colors.grey.shade50, indent: 60),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(_MenuData item) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        item.onTap();
      },
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
            ),
            Icon(CupertinoIcons.chevron_right, color: Colors.grey.shade300, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(l10n.sign_out),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFFEF2F2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade100,
        highlightColor: Colors.white,
        child: Column(
          children: [
            Container(height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
            const SizedBox(height: 32),
            Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 60, color: Colors.amber),
            const SizedBox(height: 20),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _cubit.loadProfile, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  _MenuData({required this.icon, required this.title, required this.color, required this.onTap});
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
