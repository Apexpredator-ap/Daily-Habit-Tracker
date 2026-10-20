import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';

class CompletionModel extends CompletionEntity {
  const CompletionModel({
    required super.dateKey,
    required super.habitId,
    required super.isCompleted,
    required super.pointsEarned,
    required super.completedAt,
  });

  factory CompletionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String habitId,
  ) {
    final data = doc.data() ?? {};
    return CompletionModel(
      dateKey: doc.id,
      habitId: habitId,
      isCompleted: data['isCompleted'] as bool? ?? false,
      pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
      completedAt: (data['completedAt'] is Timestamp)
          ? (data['completedAt'] as Timestamp).toDate()
          : (data['completedAt'] != null
                ? DateTime.tryParse(data['completedAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
    );
  }

  factory CompletionModel.fromEntity(CompletionEntity entity) {
    return CompletionModel(
      dateKey: entity.dateKey,
      habitId: entity.habitId,
      isCompleted: entity.isCompleted,
      pointsEarned: entity.pointsEarned,
      completedAt: entity.completedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isCompleted': isCompleted,
      'pointsEarned': pointsEarned,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
