import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';

class HabitModel extends HabitEntity {
  const HabitModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.points,
    super.isArchived = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HabitModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return HabitModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      points: (data['points'] as num?)?.toInt() ?? 0,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] != null
                ? DateTime.tryParse(data['createdAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : (data['updatedAt'] != null
                ? DateTime.tryParse(data['updatedAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
    );
  }

  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      points: entity.points,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'points': points,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
