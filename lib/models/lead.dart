class Lead {
  final int? id;
  final String name;
  final String contact; // Phone or Email
  final String status; // New, Contacted, Converted, Lost
  final String? notes;
  final DateTime createdTime;

  Lead({
    this.id,
    required this.name,
    required this.contact,
    required this.status,
    this.notes,
    required this.createdTime,
  });

  // Convert a Lead into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'status': status,
      'notes': notes,
      'createdTime': createdTime.toIso8601String(),
    };
  }

  // Convert a Map into a Lead.
  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      status: map['status'],
      notes: map['notes'],
      createdTime: DateTime.parse(map['createdTime']),
    );
  }

  Lead copyWith({
    int? id,
    String? name,
    String? contact,
    String? status,
    String? notes,
    DateTime? createdTime,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}