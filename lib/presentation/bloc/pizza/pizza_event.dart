import 'package:equatable/equatable.dart';

abstract class PizzaEvent extends Equatable {
  const PizzaEvent();

  @override
  List<Object?> get props => [];
}

class LoadPizzasEvent extends PizzaEvent {
  const LoadPizzasEvent();
}
