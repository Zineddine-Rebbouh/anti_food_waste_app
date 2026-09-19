import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/plan_selection_screen.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/payment_instructions_screen.dart';

class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingCubit, BillingState>(
      builder: (context, state) {
        if (state is! BillingLoaded) {
          return const SizedBox.shrink();
        }

        final sub = state.subscription;
        final status = sub.status.toLowerCase();

        String message = '';
        Color backgroundColor = Colors.transparent;
        Color textColor = Colors.white;
        IconData icon = Icons.info_outline;

        if (status == 'suspended') {
          message = 'Account Suspended! You cannot create new listings. Settle your balance now.';
          backgroundColor = Colors.red.shade800;
          icon = Icons.gpp_bad_rounded;
        } else if (status == 'past_due') {
          message = 'Payment Overdue! Settle your balance within grace period to avoid suspension.';
          backgroundColor = Colors.orange.shade800;
          icon = Icons.warning_amber_rounded;
        } else if (status == 'trial') {
          final days = sub.daysRemaining;
          if (days != null && days <= 7) {
            message = 'Trial ends in $days day${days == 1 ? "" : "s"}. Upgrade to Standard Plan to continue.';
            backgroundColor = const Color(0xFF1976D2);
            icon = Icons.rocket_launch_rounded;
          } else {
            return const SizedBox.shrink();
          }
        } else {
          // No banner for active or normal trials
          return const SizedBox.shrink();
        }

        return Material(
          color: backgroundColor,
          child: InkWell(
            onTap: () {
              final standardPlan = state.plans.firstWhere(
                (p) => p.slug == 'standard',
                orElse: () => SubscriptionPlan(
                  id: 2,
                  name: 'Standard Plan',
                  slug: 'standard',
                  monthlyPriceDzd: 2000.0,
                  canReceiveDonations: true,
                  isActive: true,
                ),
              );

              final isExistingSubscriber = sub.plan.slug == 'standard';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<BillingCubit>(),
                    child: isExistingSubscriber
                        ? PaymentInstructionsScreen(plan: standardPlan)
                        : const PlanSelectionScreen(),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.8), size: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
