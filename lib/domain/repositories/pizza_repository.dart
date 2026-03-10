import '../entities/pizza.dart';

abstract class PizzaRepository {
  Stream<List<Pizza>> getPizzas();
}
