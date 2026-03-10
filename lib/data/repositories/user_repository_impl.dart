import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../models/user_model.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      // Try to get from local cache first
      final localUser = await localDataSource.getUser(id);
      if (localUser != null) {
        return Either.right(localUser);
      }

      // If not in cache, fetch from remote
      final remoteUser = await remoteDataSource.getUser(id);
      await localDataSource.cacheUser(remoteUser);
      return Either.right(remoteUser);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      // Try to get from local cache first
      final localUsers = await localDataSource.getAllUsers();
      if (localUsers.isNotEmpty) {
        return Either.right(localUsers);
      }

      // If not in cache, fetch from remote
      final remoteUsers = await remoteDataSource.getAllUsers();
      await localDataSource.cacheUsers(remoteUsers);
      return Either.right(remoteUsers);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> createUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await remoteDataSource.createUser(userModel);
      await localDataSource.cacheUser(createdUser);
      return Either.right(createdUser);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUser = await remoteDataSource.updateUser(userModel);
      await localDataSource.cacheUser(updatedUser);
      return Either.right(updatedUser);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await remoteDataSource.deleteUser(id);
      await localDataSource.deleteUser(id);
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
