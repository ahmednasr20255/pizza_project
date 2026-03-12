import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/entities/order.dart' as domain;

class CartBloc extends Bloc<CartEvent, CartState> {
  final OrderRepository? orderRepository;

  CartBloc({this.orderRepository}) : super(const CartLoaded([])) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<IncreaseQuantityEvent>(_onIncreaseQuantity);
    on<DecreaseQuantityEvent>(_onDecreaseQuantity);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<ClearCartEvent>(_onClearCart);
    on<ConfirmOrderEvent>(_onConfirmOrder);
  }

  void _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final items = List<CartItem>.from(currentState.items);
      
      final existingIndex = items.indexWhere(
        (item) => item.pizza.id == event.pizza.id,
      );

      if (existingIndex >= 0) {
        // If pizza already in cart, increase quantity
        items[existingIndex] = items[existingIndex].copyWith(
          quantity: items[existingIndex].quantity + 1,
        );
      } else {
        // Add new item to cart
        items.add(CartItem(pizza: event.pizza, quantity: 1));
      }

      emit(CartLoaded(items, currentState.confirmedOrders));
    }
  }

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final items = List<CartItem>.from(currentState.items);
      
      items.removeWhere((item) => item.pizza.id == event.pizzaId);
      
      emit(CartLoaded(items, currentState.confirmedOrders));
    }
  }

  void _onIncreaseQuantity(
    IncreaseQuantityEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final items = List<CartItem>.from(currentState.items);
      
      final index = items.indexWhere(
        (item) => item.pizza.id == event.pizzaId,
      );

      if (index >= 0) {
        items[index] = items[index].copyWith(
          quantity: items[index].quantity + 1,
        );
        emit(CartLoaded(items, currentState.confirmedOrders));
      }
    }
  }

  void _onDecreaseQuantity(
    DecreaseQuantityEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final items = List<CartItem>.from(currentState.items);
      
      final index = items.indexWhere(
        (item) => item.pizza.id == event.pizzaId,
      );

      if (index >= 0) {
        if (items[index].quantity > 1) {
          items[index] = items[index].copyWith(
            quantity: items[index].quantity - 1,
          );
        } else {
          // If quantity is 1, remove from cart
          items.removeAt(index);
        }
        emit(CartLoaded(items, currentState.confirmedOrders));
      }
    }
  }

  void _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final items = List<CartItem>.from(currentState.items);
      
      items.removeWhere((item) => item.pizza.id == event.pizzaId);
      
      emit(CartLoaded(items, currentState.confirmedOrders));
    }
  }

  void _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoaded(const [], currentState.confirmedOrders));
    } else {
      emit(const CartLoaded([]));
    }
  }

  Future<void> _onConfirmOrder(
    ConfirmOrderEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final items = List<CartItem>.from(currentState.items);
      
      // Remove item from cart after confirming
      items.removeWhere((item) => item.pizza.id == event.pizzaId);
      
      // Create order and save to Firebase
      if (orderRepository != null) {
        final orderId = '${event.userId}_${event.pizza.id}_${DateTime.now().millisecondsSinceEpoch}';
        final order = domain.Order(
          id: orderId,
          userId: event.userId,
          pizzaId: event.pizza.id,
          pizzaName: event.pizza.name,
          pizzaPrice: event.pizza.price,
          pizzaImageUrl: event.pizza.imageUrl,
          quantity: event.quantity,
          totalPrice: event.pizza.price * event.quantity,
          status: domain.OrderStatus.confirmed,
          createdAt: DateTime.now(),
        );

        await orderRepository!.createOrder(order);
      }
      
      emit(CartLoaded(items, currentState.confirmedOrders));
    }
  }
}
