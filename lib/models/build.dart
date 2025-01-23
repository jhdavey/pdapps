class Build {
  final int id;
  final String make;
  final String model;
  final int year;
  final int userId;

  Build({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.userId,
  });

  // Factory constructor for creating a Build from a database record
  factory Build.fromMap(Map<String, dynamic> map) {
    return Build(
      id: map['id'] as int,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      userId: map['userId'] as int,
    );
  }

  // Convert a Build to a Map (for saving to the database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'userId': userId,
    };
  }
}
