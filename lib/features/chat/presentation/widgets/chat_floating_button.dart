import 'dart:math' as math;

import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/core/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class ChatFloatingButton extends StatefulWidget {
  const ChatFloatingButton({super.key});

  static const double width = 64;
  static const double height = 56;
  static const double visibleWidth = 48;
  static const Color accent = Color(0xFF2563EB);

  @override
  State<ChatFloatingButton> createState() => _ChatFloatingButtonState();
}

class _ChatFloatingButtonState extends State<ChatFloatingButton> {
  double? _top;
  bool _isDragging = false;

  void _openChat(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.chat);
  }

  double _defaultTop(Size bounds) {
    const minTop = 88.0;
    final maxTop = math.max(
      minTop,
      bounds.height - ChatFloatingButton.height - 24,
    );
    return (bounds.height * 0.62).clamp(minTop, maxTop).toDouble();
  }

  double _clampTop(double top, Size bounds) {
    const minTop = 24.0;
    final maxTop = math.max(
      minTop,
      bounds.height - ChatFloatingButton.height - 24,
    );
    return top.clamp(minTop, maxTop).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = l10n?.ai_assistant ?? 'AI Assistant';

    return ValueListenableBuilder<bool>(
      valueListenable: PreferencesService.chatBubbleEnabledNotifier,
      builder: (context, isVisible, _) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final bounds = constraints.biggest;
            final top = _clampTop(_top ?? _defaultTop(bounds), bounds);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedPositioned(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  left: ChatFloatingButton.visibleWidth -
                      ChatFloatingButton.width,
                  top: top,
                  width: ChatFloatingButton.width,
                  height: ChatFloatingButton.height,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openChat(context),
                    onPanStart: (_) {
                      setState(() {
                        _isDragging = true;
                        _top = top;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _top = (_top ?? top) + details.delta.dy;
                      });
                    },
                    onPanEnd: (details) {
                      final inwardSwipe =
                          details.velocity.pixelsPerSecond.dx > 700;
                      final hideThreshold = bounds.height - 88;
                      final shouldHide = (_top ?? top) > hideThreshold ||
                          details.velocity.pixelsPerSecond.dy > 900;

                      setState(() {
                        _isDragging = false;
                        if (shouldHide) {
                          _top = null;
                        } else {
                          _top = _clampTop(_top ?? top, bounds);
                        }
                      });

                      if (shouldHide) {
                        PreferencesService.setChatBubbleEnabled(false);
                        return;
                      }

                      if (inwardSwipe) {
                        _openChat(context);
                      }
                    },
                    onPanCancel: () {
                      setState(() {
                        _isDragging = false;
                        _top = _clampTop(_top ?? top, bounds);
                      });
                    },
                    child: Tooltip(
                      message: label,
                      child: Semantics(
                        button: true,
                        label: label,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), AppTheme.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(4, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.eco_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
