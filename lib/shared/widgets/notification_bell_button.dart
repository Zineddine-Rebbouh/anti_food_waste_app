import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_state.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_panel.dart';

class NotificationBellButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const NotificationBellButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        var unreadCount = 0;
        if (state is NotificationsLoaded) {
          unreadCount = state.unreadCount;
        }

        return IconButton(
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount.toString()),
            child: const Icon(CupertinoIcons.bell),
          ),
          onPressed: onPressed ?? () {
             showModalBottomSheet(
               context: context,
               isScrollControlled: true,
               backgroundColor: Colors.transparent,
               builder: (ctx) => const NotificationPanel(),
             );
          },
        );
      },
    );
  }
}
