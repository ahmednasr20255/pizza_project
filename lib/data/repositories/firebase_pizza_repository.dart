import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pizza.dart';
import '../../domain/repositories/pizza_repository.dart';
import '../models/pizza_model.dart';

class FirebasePizzaRepository implements PizzaRepository {
  final FirebaseFirestore _firestore;

  FirebasePizzaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Pizza>> getPizzas() {
    return _firestore
        .collection('pizzas')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PizzaModel.fromFirestore(doc))
            .toList());
  }
}
