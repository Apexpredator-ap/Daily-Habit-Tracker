import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/core/error/exceptions.dart';
import 'package:untitled3/features/habits/data/models/completion_model.dart';
import 'package:untitled3/features/habits/data/models/habit_model.dart';

abstract class HabitsRemoteDataSource {
  Stream<List<HabitModel>> watchHabits(String userId);
  Future<HabitModel> createHabit(HabitModel habit);
  Future<void> archiveHabit(String userId, String habitId);

  Stream<CompletionModel?> watchCompletion({
    required String userId,
    required String habitId,
    required String dateKey,
  });

  Future<CompletionModel> setCompletion({
    required String userId,
    required String habitId,
    required CompletionModel completion,
  });

  Future<List<CompletionModel>> getAllCompletionsForHabit({
    required String userId,
    required String habitId,
  });
}

class FirestoreHabitsRemoteDataSource implements HabitsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreHabitsRemoteDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> _habitsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('habits');
  }

  CollectionReference<Map<String, dynamic>> _completionsRef(
    String userId,
    String habitId,
  ) {
    return _habitsRef(userId).doc(habitId).collection('completions');
  }

  @override
  Stream<List<HabitModel>> watchHabits(String userId) {
    try {
      return _habitsRef(userId).snapshots().map((snapshot) {
        final habits = snapshot.docs
            .map((doc) => HabitModel.fromFirestore(doc))
            .where((h) => !h.isArchived)
            .toList();

        // Sort by createdAt descending in memory
        habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return habits;
      });
    } catch (e) {
      throw ServerException('Failed to watch habits: ${e.toString()}');
    }
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final docRef = _habitsRef(habit.userId).doc(habit.id);
      await docRef.set(habit.toFirestore());
      return habit;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> archiveHabit(String userId, String habitId) async {
    try {
      await _habitsRef(
        userId,
      ).doc(habitId).update({'isArchived': true, 'updatedAt': Timestamp.now()});
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<CompletionModel?> watchCompletion({
    required String userId,
    required String habitId,
    required String dateKey,
  }) {
    try {
      return _completionsRef(userId, habitId).doc(dateKey).snapshots().map((
        doc,
      ) {
        if (!doc.exists) return null;
        return CompletionModel.fromFirestore(doc, habitId);
      });
    } catch (e) {
      throw ServerException('Failed to watch completion: ${e.toString()}');
    }
  }

  @override
  Future<CompletionModel> setCompletion({
    required String userId,
    required String habitId,
    required CompletionModel completion,
  }) async {
    try {
      // Use Firestore set with merge to guarantee atomicity and idempotency
      final docRef = _completionsRef(userId, habitId).doc(completion.dateKey);
      await docRef.set(completion.toFirestore(), SetOptions(merge: true));
      return completion;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CompletionModel>> getAllCompletionsForHabit({
    required String userId,
    required String habitId,
  }) async {
    try {
      final snapshot = await _completionsRef(userId, habitId).get();
      return snapshot.docs
          .map((doc) => CompletionModel.fromFirestore(doc, habitId))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
