import '../entities/user.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  });

  Future<Either<Failure, void>> signOut();

  Stream<Either<Failure, User?>> authStateChanges();

  Future<Either<Failure, User?>> getCurrentUser();
}
