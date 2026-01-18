// ignore_for_file: immutable_class

class StatusUpdate {
  final String status;
  final DateTime timestamp;
  final String? note;
  final String? actor; // officer / system / department
  final String? actorRole; // inspector, system, director

  StatusUpdate({
    required this.status,
    required this.timestamp,
    this.note,
    this.actor,
    this.actorRole,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      status: json['status'] ?? 'UNKNOWN',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      note: json['note'],
      actor: json['actor'],
      actorRole: json['actorRole'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
    'actor': actor,
    'actorRole': actorRole,
  };
}

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String status;

  final String? location;
  final String? category;
  final String? assignedOfficer;
  final String? resolution;
  final String? priority;

  // ✅ NEW FIELD
  final String? imagePath;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final List<StatusUpdate> statusHistory;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.location,
    this.category,
    this.assignedOfficer,
    this.resolution,
    this.priority,
    this.imagePath, // ✅ Add to Constructor
    required this.createdAt,
    this.updatedAt,
    List<StatusUpdate>? statusHistory,
  }) : statusHistory = statusHistory ?? const [];

  /// -------------------------------
  /// JSON
  /// -------------------------------
  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    // ✅ CRITICAL FIX: Check ALL possible status keys from backend
    // Your logs showed the DB uses 'current_status', so we must check that too.
    String serverStatus = json['status'] ??
        json['currentStatus'] ??
        json['current_status'] ??
        'OPEN';

    return ComplaintModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',

      // ✅ Use the detected status
      status: serverStatus,

      location: json['location'],
      category: json['category'],
      assignedOfficer: json['assignedOfficer'],
      resolution: json['resolution'],
      priority: json['priority'],
      imagePath: json['imagePath'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => StatusUpdate.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'location': location,
    'category': category,
    'assignedOfficer': assignedOfficer,
    'resolution': resolution,
    'priority': priority,
    'imagePath': imagePath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
  };

  /// -------------------------------
  /// HELPERS FOR UI / ANIMATION
  /// -------------------------------

  bool get isResolved =>
      status.toUpperCase() == 'RESOLVED' ||
          status.toUpperCase() == 'CLOSED';

  bool get isActive =>
      !['RESOLVED', 'REJECTED', 'CLOSED']
          .contains(status.toUpperCase());

  int get progressPercent {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 20;
      case 'ASSIGNED':
        return 40;
      case 'INVESTIGATION':
        return 70;
      case 'RESOLVED':
        return 100;
      default:
        return 0;
    }
  }

  /// -------------------------------
  /// SAFE COPY
  /// -------------------------------
  ComplaintModel copyWith({
    String? status,
    List<StatusUpdate>? statusHistory,
    String? resolution,
    String? assignedOfficer,
    String? imagePath,
  }) {
    return ComplaintModel(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      location: location,
      category: category,
      assignedOfficer: assignedOfficer ?? this.assignedOfficer,
      resolution: resolution ?? this.resolution,
      priority: priority,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}