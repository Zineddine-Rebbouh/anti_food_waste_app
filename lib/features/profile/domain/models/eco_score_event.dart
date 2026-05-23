class EcoScoreEvent {
  final String id;
  final String eventType;
  final int delta;
  final int scoreBefore;
  final int scoreAfter;
  final String reason;
  final DateTime createdAt;

  const EcoScoreEvent({
    required this.id,
    required this.eventType,
    required this.delta,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.reason,
    required this.createdAt,
  });

  factory EcoScoreEvent.fromJson(Map<String, dynamic> json) {
    return EcoScoreEvent(
      id: json['id'] as String? ?? '',
      eventType: json['event_type'] as String? ?? 'unknown',
      delta: (json['delta'] as num? ?? 0).toInt(),
      scoreBefore: (json['score_before'] as num? ?? 0).toInt(),
      scoreAfter: (json['score_after'] as num? ?? 0).toInt(),
      reason: json['reason'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  String get typeLabel {
    switch (eventType) {
      case 'pickup_completed':
        return 'Order Collected';
      case 'pickup_completed_early':
        return 'Early Pickup Bonus';
      case 'no_show':
        return 'No-Show Penalty';
      case 'cancellation_late':
        return 'Late Cancellation';
      case 'cancellation_critical':
        return 'Critical Cancellation';
      case 'pickup_fulfilled':
        return 'Order Fulfilled';
      case 'admin_override':
        return 'Admin Adjustment';
      default:
        return eventType.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    }
  }

  bool get isPositive => delta > 0;
}
