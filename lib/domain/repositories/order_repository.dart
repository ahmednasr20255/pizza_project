import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../entities/order.dart' as domain;

abstract class OrderRepository {
  Future<Either<Failure, void>> createOrder(domain.Order order);
  Future<Either<Failure, void>> cancelOrder(String orderId);
  Stream<List<domain.Order>> getUserOrders(String userId);
  Stream<List<domain.Order>> getAllOrders();
  Future<Either<Failure, Map<String, int>>> getPizzaOrderCounts();
}
