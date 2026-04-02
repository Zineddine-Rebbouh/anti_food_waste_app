import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/onboarding/domain/models/onboarding_slide.dart';
import 'package:anti_food_waste_app/features/onboarding/presentation/widgets/onboarding_slide_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingSlide> _getSlides(AppLocalizations l10n) => [
        OnboardingSlide(
          image:
              'https://images.unsplash.com/photo-1628697639527-e370a51de205?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmVzaCUyMEFsZ2VyaWFuJTIwYnJlYWQlMjBwYXN0cmllcyUyMGJha2VyeXxlbnwxfHx8fDE3NzE4NjEwNDl8MA&ixlib=rb-4.1.0&q=80&w=1080',
          headline: l10n.slide1_headline,
          subtext: l10n.slide1_subtext,
          icon: Icons.trending_down,
        ),
        OnboardingSlide(
          image:
              'https://images.unsplash.com/photo-1681072953579-9cd240410ac1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkaXZlcnNlJTIwQWxnZXJpYW4lMjBwZW9wbGUlMjB1c2luZyUyMHNtYXJ0cGhvbmUlMjBoYXBweXxlbnwxfHx8fDE3NzE4NjEwNTF8MA&ixlib=rb-4.1.0&q=80&w=1080',
          headline: l10n.slide2_headline,
          subtext: l10n.slide2_subtext,
          icon: Icons.people,
        ),
        OnboardingSlide(
          image:
              'https://images.unsplash.com/photo-1710092784814-4a6f158913b8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2b2x1bnRlZXIlMjBnaXZpbmclMjBmb29kJTIwZG9uYXRpb24lMjBjb21tdW5pdHl8ZW58MXx8fHwxNzcxODYxMDUxfDA&ixlib=rb-4.1.0&q=80&w=1080',
          headline: l10n.slide3_headline,
          subtext: l10n.slide3_subtext,
          icon: Icons.favorite,
        ),
      ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _handleNext(int slideCount) {
    if (_currentPage < slideCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToWelcome();
    }
  }

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    final slides = _getSlides(l10n);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return OnboardingSlideView(
                slide: slides[index],
                isLast: index == slides.length - 1,
              );
            },
          ),

          // Skip Button
          Positioned(
            top: 50,
            right: isRTL ? null : 20,
            left: isRTL ? 20 : null,
            child: TextButton(
              onPressed: _navigateToWelcome,
              child: Text(
                l10n.skip,
                style: const TextStyle(
                  color: AppTheme.mutedForeground,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primary
                            : AppTheme.border.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _handleNext(slides.length),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.primaryForeground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == slides.length - 1
                              ? l10n.getStarted
                              : l10n.next,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isRTL ? Icons.chevron_left : Icons.chevron_right,
                        ),
                      ],
                    ),
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
