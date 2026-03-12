import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/firebase_pizza_repository.dart';
import 'data/repositories/firebase_order_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/pizza/pizza_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/orders/orders_bloc.dart';
import 'presentation/pages/login_page.dart';

bool _firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if google-services.json exists
  try {
    await Firebase.initializeApp();
    _firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // Firebase not configured yet - app will run without Firebase
    _firebaseInitialized = false;
    debugPrint('Firebase initialization skipped: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Only create FirebaseAuthRepository if Firebase is initialized
    if (!_firebaseInitialized) {
      return MaterialApp(
        title: 'Pizza Project',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Pizza Project'),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Firebase Not Configured',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please add google-services.json file to android/app/ directory and ensure Firebase is properly configured.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: FirebaseAuthRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => PizzaBloc(
            pizzaRepository: FirebasePizzaRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => CartBloc(
            orderRepository: FirebaseOrderRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => OrdersBloc(
            orderRepository: FirebaseOrderRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Pizza Project',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
