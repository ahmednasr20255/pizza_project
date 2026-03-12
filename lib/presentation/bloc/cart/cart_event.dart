import 'package:equatable/equatable.dart';
import '../../../domain/entities/pizza.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends CartEvent {
  final Pizza pizza;

  const AddToCartEvent(this.pizza);

  @override
  List<Object?> get props => [pizza];
}

class RemoveFromCartEvent extends CartEvent {
  final String pizzaId;

  const RemoveFromCartEvent(this.pizzaId);

  @override
  List<Object?> get props => [pizzaId];
}

class IncreaseQuantityEvent extends CartEvent {
  final String pizzaId;

  const IncreaseQuantityEvent(this.pizzaId);

  @override
  List<Object?> get props => [pizzaId];
}

class DecreaseQuantityEvent extends CartEvent {
  final String pizzaId;

  const DecreaseQuantityEvent(this.pizzaId);

  @override
  List<Object?> get props => [pizzaId];
}

class DeleteOrderEvent extends CartEvent {
  final String pizzaId;

  const DeleteOrderEvent(this.pizzaId);

  @override
  List<Object?> get props => [pizzaId];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

class ConfirmOrderEvent extends CartEvent {
  final String pizzaId;
  final int quantity;
  final String userId;
  final Pizza pizza;

  const ConfirmOrderEvent({
    required this.pizzaId,
    required this.quantity,
    required this.userId,
    required this.pizza,
  });

  @override
  List<Object?> get props => [pizzaId, quantity, userId, pizza];
}
