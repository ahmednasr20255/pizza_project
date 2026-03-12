import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pizza.dart';
import '../pages/pizza_detail_screen.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class PizzaCard extends StatelessWidget {
  final Pizza pizza;

  const PizzaCard({
    super.key,
    required this.pizza,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PizzaDetailScreen(pizza: pizza),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pizza.imageUrl != null && pizza.imageUrl!.isNotEmpty)
              Image.network(
                pizza.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.local_pizza,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          pizza.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${pizza.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {}, // Prevent InkWell tap
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        if (cartState is CartLoaded) {
                          final isInCart = cartState.isInCart(pizza.id);
                          final quantity = cartState.getQuantityForPizza(pizza.id);

                          if (isInCart && quantity > 0) {
                            // Show quantity controls, confirm order and delete button
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Quantity controls
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                              DecreaseQuantityEvent(pizza.id),
                                            );
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                              IncreaseQuantityEvent(pizza.id),
                                            );
                                      },
                                      icon: const Icon(Icons.add_circle_outline),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                                // Confirm Order and Delete buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, authState) {
                                        if (authState is AuthAuthenticated) {
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              context.read<CartBloc>().add(
                                                    ConfirmOrderEvent(
                                                      pizzaId: pizza.id,
                                                      quantity: quantity,
                                                      userId: authState.user.id,
                                                      pizza: pizza,
                                                    ),
                                                  );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Order confirmed: ${pizza.name} x$quantity'),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.check_circle_outline, size: 18),
                                            label: const Text('Confirm Order'),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                              DeleteOrderEvent(pizza.id),
                                            );
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                      tooltip: 'Delete Order',
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // Show "Add to Cart" button
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        AddToCartEvent(pizza),
                                      );
                                },
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text('Add to Cart'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            );
                          }
                        }
                        // Default: Show "Add to Cart" button
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<CartBloc>().add(
                                    AddToCartEvent(pizza),
                                  );
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
