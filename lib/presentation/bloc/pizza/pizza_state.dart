import 'package:equatable/equatable.dart';
import '../../../domain/entities/pizza.dart';

abstract class PizzaState extends Equatable {
  const PizzaState();

  @override
  List<Object?> get props => [];
}

class PizzaInitial extends PizzaState {
  const PizzaInitial();
}

class PizzaLoading extends PizzaState {
  const PizzaLoading();
}

class PizzaLoaded extends PizzaState {
  final List<Pizza> pizzas;

  const PizzaLoaded(this.pizzas);

  @override
  List<Object?> get props => [pizzas];
}

class PizzaError extends PizzaState {
  final String message;

  const PizzaError(this.message);

  @override
  List<Object?> get props => [message];
}
