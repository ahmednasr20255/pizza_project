import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pizza/pizza_bloc.dart';
import '../bloc/pizza/pizza_event.dart';
import '../bloc/pizza/pizza_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/orders/orders_bloc.dart';
import '../bloc/orders/orders_event.dart';
import '../../data/repositories/firebase_order_repository.dart';
import '../widgets/pizza_card.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load pizzas when screen is initialized
    context.read<PizzaBloc>().add(const LoadPizzasEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza Menu'),
        centerTitle: true,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () {
                    // Load orders before navigating
                    context.read<OrdersBloc>().add(
                          LoadUserOrdersEvent(authState.user.id),
                        );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    );
                  },
                  tooltip: 'My Orders',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<PizzaBloc, PizzaState>(
        builder: (context, state) {
            if (state is PizzaInitial || state is PizzaLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is PizzaError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PizzaBloc>().add(const LoadPizzasEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PizzaLoaded) {
              if (state.pizzas.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pizza,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No pizzas available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return FutureBuilder<Map<String, int>>(
                future: _getPizzaOrderCounts(),
                builder: (context, snapshot) {
                  Map<String, int> orderCounts = {};
                  if (snapshot.hasData) {
                    orderCounts = snapshot.data!;
                  }

                  // Sort pizzas by order counts (most ordered first)
                  final sortedPizzas = List.from(state.pizzas);
                  sortedPizzas.sort((a, b) {
                    final aOrders = orderCounts[a.id] ?? 0;
                    final bOrders = orderCounts[b.id] ?? 0;
                    return bOrders.compareTo(aOrders);
                  });

                  // Get top rated pizzas (top 3 most ordered)
                  final topRatedPizzas = sortedPizzas
                      .where((pizza) => (orderCounts[pizza.id] ?? 0) > 0)
                      .take(3)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Top Rated Section
                      if (topRatedPizzas.isNotEmpty) ...[
                        Text(
                          'Top Rated',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...topRatedPizzas.map((pizza) {
                          final orderCount = orderCounts[pizza.id] ?? 0;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              title: Text(pizza.name),
                              subtitle: Text('$orderCount orders'),
                              trailing: Text(
                                '\$${pizza.price.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        Text(
                          'All Pizzas',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // All Pizzas List
                      ...state.pizzas.map((pizza) => PizzaCard(pizza: pizza)),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
    );
  }

  Future<Map<String, int>> _getPizzaOrderCounts() async {
    try {
      final repository = FirebaseOrderRepository();
      final result = await repository.getPizzaOrderCounts();
      return result.fold(
        (failure) => <String, int>{},
        (counts) => counts,
      );
    } catch (e) {
      return <String, int>{};
    }
  }
}
