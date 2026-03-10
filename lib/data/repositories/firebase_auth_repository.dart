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
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Either.left(const AuthFailure('Sign in failed: No user returned'));
      }

      // Fetch user data from Firestore or use Firebase Auth data
      final user = UserModel.fromFirebaseUser(userCredential.user!);
      return Either.right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Either.left(AuthFailure('Sign in failed: ${e.message ?? e.code}'));
    } catch (e) {
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
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Either.left(const AuthFailure('Sign up failed: No user returned'));
      }

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      final user = UserModel.fromFirebaseUser(
        userCredential.user!,
        name: name,
        phoneNumber: phoneNumber,
      );

      return Either.right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Either.left(AuthFailure('Sign up failed: ${e.message ?? e.code}'));
    } catch (e) {
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
