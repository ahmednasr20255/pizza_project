import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pizza/pizza_bloc.dart';
import '../bloc/pizza/pizza_event.dart';
import '../bloc/pizza/pizza_state.dart';
import '../widgets/pizza_card.dart';

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

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.pizzas.length,
                itemBuilder: (context, index) {
                  return PizzaCard(pizza: state.pizzas[index]);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
    );
  }
}
