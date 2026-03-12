import '../../domain/entities/order.dart' as domain;
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel extends domain.Order {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.pizzaId,
    required super.pizzaName,
    required super.pizzaPrice,
    super.pizzaImageUrl,
    required super.quantity,
    required super.totalPrice,
    required super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String,
      pizzaId: data['pizzaId'] as String,
      pizzaName: data['pizzaName'] as String,
      pizzaPrice: (data['pizzaPrice'] as num).toDouble(),
      pizzaImageUrl: data['pizzaImageUrl'] as String?,
      quantity: data['quantity'] as int,
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: domain.OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status'] as String}',
        orElse: () => domain.OrderStatus.confirmed,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'pizzaId': pizzaId,
      'pizzaName': pizzaName,
      'pizzaPrice': pizzaPrice,
      'pizzaImageUrl': pizzaImageUrl,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory OrderModel.fromEntity(domain.Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      pizzaId: order.pizzaId,
      pizzaName: order.pizzaName,
      pizzaPrice: order.pizzaPrice,
      pizzaImageUrl: order.pizzaImageUrl,
      quantity: order.quantity,
      totalPrice: order.totalPrice,
      status: order.status,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }
}
