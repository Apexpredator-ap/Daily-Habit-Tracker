import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled3/core/error/exceptions.dart';
import 'package:untitled3/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInAnonymously();
  UserEntity? getCurrentUser();
  Future<void> signOut();
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRemoteDataSource(this._firebaseAuth);

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Failed to get user after anonymous sign in');
      }
      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication error', code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
