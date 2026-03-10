import '../../domain/entities/pizza.dart';
import '../../domain/repositories/pizza_repository.dart';
import 'dart:async';

class PizzaRepositoryImpl implements PizzaRepository {
  PizzaRepositoryImpl();

  @override
  Stream<List<Pizza>> getPizzas() {
    // This is a placeholder implementation
    // Use FirebasePizzaRepository for actual Firestore implementation
    return Stream.value([]);
  }
}
