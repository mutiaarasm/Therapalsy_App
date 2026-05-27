enum MonitoringSessionStatus {
  upcoming,
  available,
  completed,
  missed,
}

class MonitoringSessionModel {
  final int sessionNumber;
  final DateTime scheduledDate;
  final MonitoringSessionStatus status;
  final int? score;
  final DateTime? completedAt;

  MonitoringSessionModel({
    required this.sessionNumber,
    required this.scheduledDate,
    required this.status,
    this.score,
    this.completedAt,
  });

  MonitoringSessionModel copyWith({
    int? sessionNumber,
    DateTime? scheduledDate,
    MonitoringSessionStatus? status,
    int? score,
    DateTime? completedAt,
  }) {
    return MonitoringSessionModel(
      sessionNumber: sessionNumber ?? this.sessionNumber,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}