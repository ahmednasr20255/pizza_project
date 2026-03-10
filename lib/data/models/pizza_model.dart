import '../../domain/entities/pizza.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PizzaModel extends Pizza {
  const PizzaModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.ingredients,
    super.imageUrl,
    required super.createdAt,
    super.updatedAt,
  });

  factory PizzaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PizzaModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      ingredients: List<String>.from(data['ingredients'] as List? ?? []),
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory PizzaModel.fromJson(Map<String, dynamic> json) {
    return PizzaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      ingredients: List<String>.from(json['ingredients'] as List),
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PizzaModel.fromEntity(Pizza pizza) {
    return PizzaModel(
      id: pizza.id,
      name: pizza.name,
      description: pizza.description,
      price: pizza.price,
      ingredients: pizza.ingredients,
      imageUrl: pizza.imageUrl,
      createdAt: pizza.createdAt,
      updatedAt: pizza.updatedAt,
    );
  }
}
