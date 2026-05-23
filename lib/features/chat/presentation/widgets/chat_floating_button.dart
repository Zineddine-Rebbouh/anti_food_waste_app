import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class ChatFloatingButton extends StatelessWidget {
  const ChatFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'chat_fab',
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.chat);
      },
      backgroundColor: AppTheme.primary,
      elevation: 4.0,
      child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
    );
  }
}
