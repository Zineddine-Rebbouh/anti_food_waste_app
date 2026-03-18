import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/notifications/presentation/cubits/notifications_cubit.dart';
import '../../features/notifications/presentation/cubits/notifications_state.dart';
import 'notification_panel.dart';

class NotificationBellButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const NotificationBellButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        int unreadCount = 0;
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
