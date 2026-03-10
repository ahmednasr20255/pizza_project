import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pizza_repository.dart';
import 'pizza_event.dart';
import 'pizza_state.dart';

class PizzaBloc extends Bloc<PizzaEvent, PizzaState> {
  final PizzaRepository pizzaRepository;

  PizzaBloc({required this.pizzaRepository}) : super(const PizzaInitial()) {
    on<LoadPizzasEvent>(_onLoadPizzas);
  }

  Future<void> _onLoadPizzas(
    LoadPizzasEvent event,
    Emitter<PizzaState> emit,
  ) async {
    emit(const PizzaLoading());

    await emit.forEach(
      pizzaRepository.getPizzas(),
      onData: (pizzas) => PizzaLoaded(pizzas),
      onError: (error, stackTrace) => PizzaError(error.toString()),
    );
  }
}
