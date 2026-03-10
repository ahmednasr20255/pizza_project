import 'package:equatable/equatable.dart';

class Pizza extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> ingredients;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Pizza({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.ingredients,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        ingredients,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
