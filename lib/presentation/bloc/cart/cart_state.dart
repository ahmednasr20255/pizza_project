import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final Map<String, int> confirmedOrders; // pizzaId -> total confirmed quantity

  const CartLoaded(this.items, [this.confirmedOrders = const {}]);

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  int getQuantityForPizza(String pizzaId) {
    try {
      final item = items.firstWhere(
        (item) => item.pizza.id == pizzaId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  bool isInCart(String pizzaId) {
    return items.any((item) => item.pizza.id == pizzaId);
  }

  int getConfirmedOrdersForPizza(String pizzaId) {
    return confirmedOrders[pizzaId] ?? 0;
  }

  @override
  List<Object?> get props => [items, confirmedOrders];
}
