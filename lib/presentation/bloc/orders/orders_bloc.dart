import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../core/errors/failures.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository orderRepository;

  OrdersBloc({required this.orderRepository}) : super(const OrdersInitial()) {
    on<LoadUserOrdersEvent>(_onLoadUserOrders);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onLoadUserOrders(
    LoadUserOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());

    await emit.forEach(
      orderRepository.getUserOrders(event.userId),
      onData: (orders) => OrdersLoaded(orders),
      onError: (error, stackTrace) => OrdersError(error.toString()),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await orderRepository.cancelOrder(event.orderId);

    result.fold(
      (failure) {
        emit(OrdersError(_getErrorMessage(failure)));
        // Reload orders after error
        if (state is OrdersLoaded) {
          final currentState = state as OrdersLoaded;
          emit(OrdersLoaded(currentState.orders));
        }
      },
      (_) {
        // Order cancelled successfully, state will update via stream
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'An unexpected error occurred';
  }
}
