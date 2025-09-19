import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:pinksmapmobile/utils/theme.dart';
import 'screens/login_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/image_search_controller.dart';
import 'services/stripe_service.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/logger.dart';
import 'utils/color_extension.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      Logger.info('Starting app initialization');
      
      // Initialize Firebase with error handling
      Logger.info('Initializing Firebase');
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        Logger.info('Firebase initialized successfully');
      } catch (e) {
        Logger.error('Firebase initialization failed', error: e);
        // Continue without Firebase in web for debugging
        if (!kIsWeb) {
          rethrow;
        }
      }
      
      // Initialize Stripe with error handling
      Logger.info('Initializing Stripe');
      try {
        if (!kIsWeb) {
          // Skip Stripe initialization on web for now
          StripeService().init();
          Logger.info('Stripe initialized successfully');
        } else {
          Logger.info('Skipping Stripe initialization on web');
        }
      } catch (e) {
        Logger.error('Stripe initialization failed', error: e);
        // Continue without Stripe
      }
      
      // Initialize controllers
      Logger.info('Initializing controllers');
      try {
        Get.put(AuthController());
        Get.put(ProductController());
        Get.put(CartController());
        Get.put(OrderController());
        Get.put(ImageSearchController());
        Logger.info('Controllers initialized successfully');
      } catch (e) {
        Logger.error('Controller initialization failed', error: e);
        // Continue with minimal functionality
      }
      
      Logger.info('App initialization completed, running app');
      runApp(const PinkSnapApp());
    } catch (error) {
      Logger.error('Error during app startup: $error', error: error);
      // Run a minimal fallback app
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error starting app: $error'),
          ),
        ),
      ));
    }
  }, (error, stack) {
    Logger.error('Uncaught exception in app', error: error);
  });
}

class PinkSnapApp extends StatefulWidget {
  const PinkSnapApp({super.key});

  @override
  State<PinkSnapApp> createState() => _PinkSnapAppState();
}

class _PinkSnapAppState extends State<PinkSnapApp> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Add a small delay to ensure everything is properly initialized
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Error during app initialization', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error initializing app: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PinkSnap',
      theme: AppTheme.lightTheme,
      home: _isLoading 
          ? const _LoadingScreen() 
          : (_errorMessage.isNotEmpty 
              ? _ErrorScreen(errorMessage: _errorMessage) 
              : const LoginScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'PinkSnap',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String errorMessage;
  
  const _ErrorScreen({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart app
                  Get.offAll(() => const PinkSnapApp());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
