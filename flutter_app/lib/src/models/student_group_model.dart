class StudentGroupModel {
  final String id;
  final String name;
  final String academyId;
  final List<String> studentIds;

  StudentGroupModel({
    required this.id,
    required this.name,
    required this.academyId,
    required this.studentIds,
  });

  factory StudentGroupModel.fromMap(Map<String, dynamic> map) {
    return StudentGroupModel(
      id: map['id'] as String,
      name: map['name'] as String,
      academyId: map['academy_id'] as String,
      studentIds: (map['student_ids'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'academy_id': academyId,
      'student_ids': studentIds,
    };
  }
}