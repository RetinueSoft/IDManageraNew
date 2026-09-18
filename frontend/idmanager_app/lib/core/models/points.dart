import 'enums.dart';

class PointTransaction {
  final DateTime date;
  final String description;
  final int points;
  final PointTransType type;
  final PointStatus status;

  PointTransaction({
    required this.date,
    required this.description,
    required this.points,
    required this.type,
    required this.status,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) => PointTransaction(
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        description: json['description'] as String? ?? '',
        points: json['points'] as int? ?? 0,
        type: PointTransType.fromInt(json['type'] as int? ?? 1),
        status: PointStatus.fromInt(json['status'] as int? ?? 1),
      );
}
