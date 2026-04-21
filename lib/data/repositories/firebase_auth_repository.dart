import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    debugPrint('FirebaseAuthRepository: Starting sign in for email: $email');
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('FirebaseAuthRepository: Sign in successful, user: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        debugPrint('FirebaseAuthRepository: No user returned from sign in');
        return Either.left(const AuthFailure('Sign in failed: No user returned'));
      }

      // Fetch user data from Firestore or use Firebase Auth data
      final user = UserModel.fromFirebaseUser(userCredential.user!);
      debugPrint('FirebaseAuthRepository: User model created: ${user.email}');
      return Either.right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthRepository: FirebaseAuthException - ${e.code}: ${e.message}');
      return Either.left(AuthFailure('Sign in failed: ${e.message ?? e.code}'));
    } catch (e) {
      debugPrint('FirebaseAuthRepository: Unexpected error - $e');
      return Either.left(AuthFailure('Sign in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    debugPrint('FirebaseAuthRepository: Starting sign up for email: $email, name: $name');
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('FirebaseAuthRepository: User created successfully, uid: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        debugPrint('FirebaseAuthRepository: No user returned from sign up');
        return Either.left(const AuthFailure('Sign up failed: No user returned'));
      }

      // Update display name (optional - don't fail if this doesn't work)
      try {
        await userCredential.user!.updateDisplayName(name);
        debugPrint('FirebaseAuthRepository: Display name updated to: $name');
      } catch (e) {
        debugPrint('FirebaseAuthRepository: Failed to update display name (continuing anyway): $e');
      }

      debugPrint('FirebaseAuthRepository: Creating user model...');
      final user = UserModel.fromFirebaseUser(
        userCredential.user!,
        name: name,
        phoneNumber: phoneNumber,
      );

      debugPrint('FirebaseAuthRepository: User model created: ${user.email}');
      debugPrint('FirebaseAuthRepository: Registration process completed successfully');
      return Either.right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthRepository: FirebaseAuthException in sign up - ${e.code}: ${e.message}');
      return Either.left(AuthFailure('Sign up failed: ${e.message ?? e.code}'));
    } catch (e) {
      debugPrint('FirebaseAuthRepository: Unexpected error in sign up - $e');
      return Either.left(AuthFailure('Sign up failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Either.right(null);
    } catch (e) {
      return Either.left(AuthFailure('Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, User?>> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return Either.right(null);
      }

      try {
        final user = UserModel.fromFirebaseUser(firebaseUser);
        return Either.right(user);
      } catch (e) {
        return Either.left(AuthFailure('Error converting Firebase user: ${e.toString()}'));
      }
    });
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return Either.right(null);
      }

      final user = UserModel.fromFirebaseUser(firebaseUser);
      return Either.right(user);
    } catch (e) {
      return Either.left(AuthFailure('Error getting current user: ${e.toString()}'));
    }
  }
}
