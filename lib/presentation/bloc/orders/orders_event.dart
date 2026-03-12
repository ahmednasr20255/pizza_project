import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserOrdersEvent extends OrdersEvent {
  final String userId;

  const LoadUserOrdersEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CancelOrderEvent extends OrdersEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
