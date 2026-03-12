import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  cancelled,
}

class Order extends Equatable {
  final String id;
  final String userId;
  final String pizzaId;
  final String pizzaName;
  final double pizzaPrice;
  final String? pizzaImageUrl;
  final int quantity;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.pizzaId,
    required this.pizzaName,
    required this.pizzaPrice,
    this.pizzaImageUrl,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        pizzaId,
        pizzaName,
        pizzaPrice,
        pizzaImageUrl,
        quantity,
        totalPrice,
        status,
        createdAt,
        updatedAt,
      ];
}
