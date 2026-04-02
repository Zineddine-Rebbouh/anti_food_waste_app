import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/widgets/charity_status_badge.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_confirm_collection_screen.dart';

class CharityRequestsScreen extends StatefulWidget {
  const CharityRequestsScreen({super.key});

  @override
  State<CharityRequestsScreen> createState() =>
      _CharityRequestsScreenState();
}

class _CharityRequestsScreenState
    extends State<CharityRequestsScreen> {
  int _selectedTab = 0;

  List<CharityPickupRequest> _getActiveRequests(List<CharityPickupRequest> requests) =>
      requests
          .where((r) =>
              r.status == PickupRequestStatus.pending ||
              r.status == PickupRequestStatus.approved ||
              r.status == PickupRequestStatus.enRoute)
          .toList();

  List<CharityPickupRequest> _getCompletedRequests(List<CharityPickupRequest> requests) =>
      requests
          .where((r) =>
              r.status == PickupRequestStatus.collected ||
              r.status == PickupRequestStatus.cancelled)
          .toList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharityCubit, CharityState>(
      builder: (context, state) {
        if (state is CharityLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F7F9),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final List<CharityPickupRequest> requests = state is CharityLoaded ? state.myRequests : [];
        final activeRequests = _getActiveRequests(requests);
        final completedRequests = _getCompletedRequests(requests);

        return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Pickups',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildTabRow(activeRequests, completedRequests),
          Expanded(
            child: _selectedTab == 0
                ? _buildRequestList(activeRequests)
                : _buildRequestList(completedRequests),
          ),
        ],
      ),
    );
      },
    );
  }

  // ── Tab Row ─────────────────────────────────────────────────────────────────

  Widget _buildTabRow(List<CharityPickupRequest> activeReq, List<CharityPickupRequest> completedReq) {
    final tabs = [
      {'label': 'Active', 'count': activeReq.length},
      {'label': 'Completed', 'count': completedReq.length},
    ];

    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          final label = tabs[i]['label'] as String;
          final count = tabs[i]['count'] as int;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade200,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Request List ────────────────────────────────────────────────────────────

  Widget _buildRequestList(List<CharityPickupRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No requests here',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        return _PickupRequestCard(
          request: req,
          onActionTap: req.status == PickupRequestStatus.approved
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CharityConfirmCollectionScreen(request: req),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }
}

// ── _PickupRequestCard ───────────────────────────────────────────────────────

class _PickupRequestCard extends StatelessWidget {
  const _PickupRequestCard({
    required this.request,
    this.onActionTap,
  });

  final CharityPickupRequest request;
  final VoidCallback? onActionTap;

  Color get _statusColor {
    switch (request.status) {
      case PickupRequestStatus.pending:
        return Colors.amber.shade700;
      case PickupRequestStatus.approved:
        return Colors.blue.shade600;
      case PickupRequestStatus.enRoute:
        return Colors.purple.shade600;
      case PickupRequestStatus.collected:
        return AppTheme.primary;
      case PickupRequestStatus.cancelled:
        return AppTheme.accent;
    }
  }

  IconData get _statusIcon {
    switch (request.status) {
      case PickupRequestStatus.pending:
        return Icons.hourglass_top_rounded;
      case PickupRequestStatus.approved:
        return Icons.check_circle_outline_rounded;
      case PickupRequestStatus.enRoute:
        return Icons.local_shipping_outlined;
      case PickupRequestStatus.collected:
        return Icons.task_alt_rounded;
      case PickupRequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month  $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final showTimeline = request.status == PickupRequestStatus.approved ||
        request.status == PickupRequestStatus.enRoute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _statusIcon,
                        size: 18,
                        color: _statusColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        request.donationTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    CharityStatusBadge(status: request.status),
                  ],
                ),
                const SizedBox(height: 8),

                // Merchant name
                Text(
                  request.merchantName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),

                // Scheduled time
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppTheme.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(request.scheduledPickupTime),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Quantity + servings
                Row(
                  children: [
                    _SmallChip(
                      icon: Icons.scale_outlined,
                      label: '${request.quantityKg} kg',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    _SmallChip(
                      icon: Icons.restaurant_outlined,
                      label: '${request.estimatedServings} servings',
                      color: Colors.orange.shade700,
                    ),
                  ],
                ),

                // Merchant note
                if (request.merchantNote != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            request.merchantNote!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Status-specific action
                _buildStatusAction(context),
              ],
            ),
          ),
        ),

        // Timeline for approved/enRoute
        if (showTimeline) _buildTimeline(),
      ],
    );
  }

  Widget _buildStatusAction(BuildContext context) {
    switch (request.status) {
      case PickupRequestStatus.approved:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onActionTap,
            icon: const Icon(Icons.check_circle_outline_rounded,
                size: 18),
            label: const Text(
              'Mark as Collected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        );

      case PickupRequestStatus.pending:
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 14,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 6),
              const Text(
                'Awaiting merchant approval',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
        );

      case PickupRequestStatus.enRoute:
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 14,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'In Transit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        );

      case PickupRequestStatus.collected:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.task_alt_rounded,
                    size: 14,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'View Impact',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.info,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );

      case PickupRequestStatus.cancelled:
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 14,
                color: Colors.red.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'Cancelled',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildTimeline() {
    final steps = [
      {'label': 'Request Sent', 'done': true},
      {
        'label': 'Merchant Approved',
        'done': request.status == PickupRequestStatus.approved ||
            request.status == PickupRequestStatus.enRoute ||
            request.status == PickupRequestStatus.collected,
      },
      {
        'label': 'En Route',
        'done': request.status == PickupRequestStatus.enRoute ||
            request.status == PickupRequestStatus.collected,
        'inProgress': request.status == PickupRequestStatus.enRoute,
      },
      {
        'label': 'Collected',
        'done': request.status == PickupRequestStatus.collected,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          left: BorderSide(color: Colors.grey.shade100),
          right: BorderSide(color: Colors.grey.shade100),
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final isDone = steps[stepIndex]['done'] as bool? ?? false;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone
                    ? AppTheme.primary
                    : Colors.grey.shade200,
              ),
            );
          }
          final s = steps[i ~/ 2];
          final isDone = s['done'] as bool? ?? false;
          final isInProgress = s['inProgress'] as bool? ?? false;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppTheme.primary
                      : isInProgress
                          ? Colors.orange
                          : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: isInProgress
                    ? const Icon(Icons.circle, size: 8, color: Colors.white)
                    : isDone
                        ? const Icon(Icons.check, size: 12,
                            color: Colors.white)
                        : null,
              ),
              const SizedBox(height: 4),
              Text(
                s['label'] as String,
                style: TextStyle(
                  fontSize: 9,
                  color: isDone
                      ? AppTheme.primary
                      : isInProgress
                          ? Colors.orange
                          : Colors.grey.shade400,
                  fontWeight:
                      isDone ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Helper ───────────────────────────────────────────────────────────────────

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
