import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final int points;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HabitEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.points,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  HabitEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? points,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    points,
    isArchived,
    createdAt,
    updatedAt,
  ];
}
