import '../models/pizza_model.dart';

abstract class PizzaLocalDataSource {
  Future<PizzaModel?> getPizza(String id);
  Future<List<PizzaModel>> getAllPizzas();
  Future<void> cachePizza(PizzaModel pizza);
  Future<void> cachePizzas(List<PizzaModel> pizzas);
  Future<void> deletePizza(String id);
  Future<void> clearCache();
}
