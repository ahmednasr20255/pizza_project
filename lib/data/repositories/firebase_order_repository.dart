import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order.dart' as domain;
import '../../domain/repositories/order_repository.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../models/order_model.dart';
import 'dart:async';

class FirebaseOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore;

  FirebaseOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, void>> createOrder(domain.Order order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      await _firestore
          .collection('orders')
          .doc(order.id)
          .set(orderModel.toFirestore());
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Failed to create order: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': domain.OrderStatus.cancelled.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Failed to cancel order: ${e.toString()}'));
    }
  }

  @override
  Stream<List<domain.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: domain.OrderStatus.confirmed.toString().split('.').last)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          // Sort by createdAt descending
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  @override
  Stream<List<domain.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: domain.OrderStatus.confirmed.toString().split('.').last)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          // Sort by createdAt descending
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  @override
  Future<Either<Failure, Map<String, int>>> getPizzaOrderCounts() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: domain.OrderStatus.confirmed.toString().split('.').last)
          .get();

      final Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final pizzaId = data['pizzaId'] as String? ?? '';
        final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
        if (pizzaId.isNotEmpty) {
          counts[pizzaId] = (counts[pizzaId] ?? 0) + quantity;
        }
      }

      return Either.right(counts);
    } catch (e) {
      return Either.left(ServerFailure('Failed to get order counts: ${e.toString()}'));
    }
  }
}
