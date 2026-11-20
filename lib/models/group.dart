import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.joinCode,
    required this.memberIds,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String teacherId;
  final String teacherName;
  final String joinCode;
  final List<String> memberIds; // includes the teacher
  final DateTime createdAt;

  int get studentCount => memberIds.length > 1 ? memberIds.length - 1 : 0;
  String get studentsLabel =>
      '$studentCount ${studentCount == 1 ? 'student' : 'students'}';

  factory Group.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Group(
      id: doc.id,
      name: (d['name'] as String?) ?? 'Untitled group',
      teacherId: (d['teacherId'] as String?) ?? '',
      teacherName: (d['teacherName'] as String?) ?? '',
      joinCode: (d['joinCode'] as String?) ?? '',
      memberIds: List<String>.from(d['memberIds'] ?? const []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
