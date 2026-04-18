class BinEvent {
  final String id;
  final String eventName;
  final String timestamp;

  BinEvent({
    required this.id,
    required this.eventName,
    required this.timestamp,
  });

  factory BinEvent.fromJson(Map<String, dynamic> json) {
    return BinEvent(
      id: json['id']?.toString() ?? '',
      eventName: json['eventName']?.toString() ?? 'Невідома подія',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'eventName': eventName, 'timestamp': timestamp};
  }
}
