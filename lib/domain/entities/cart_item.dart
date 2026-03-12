import 'package:equatable/equatable.dart';
import 'pizza.dart';

class CartItem extends Equatable {
  final Pizza pizza;
  final int quantity;

  const CartItem({
    required this.pizza,
    required this.quantity,
  });

  double get totalPrice => pizza.price * quantity;

  CartItem copyWith({
    Pizza? pizza,
    int? quantity,
  }) {
    return CartItem(
      pizza: pizza ?? this.pizza,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [pizza.id, quantity];
}
