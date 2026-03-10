import '../models/pizza_model.dart';

abstract class PizzaRemoteDataSource {
  Future<PizzaModel> getPizza(String id);
  Future<List<PizzaModel>> getAllPizzas();
  Future<PizzaModel> createPizza(PizzaModel pizza);
  Future<PizzaModel> updatePizza(PizzaModel pizza);
  Future<void> deletePizza(String id);
}
