import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class TawfirLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  final double strokeWidth;

  const TawfirLoadingIndicator({
    super.key,
    this.size = 70.0,
    this.color,
    this.message,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppTheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size * 0.75,
                  height: size * 0.75,
                  child: CircularProgressIndicator(
                    color: themeColor,
                    strokeWidth: strokeWidth,
                  ),
                ),
                Icon(
                  Icons.eco_rounded,
                  color: themeColor.withOpacity(0.7),
                  size: size * 0.35,
                ),
              ],
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
