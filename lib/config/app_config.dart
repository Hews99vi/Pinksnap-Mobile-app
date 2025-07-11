class AppConfig {
  // App Environment
  static const bool isDevelopment = true;
  static const bool isDemoMode = false; // Using real Stripe now
  
  // Payment Configuration
  static const PaymentMode paymentMode = PaymentMode.stripeTest; // Using Stripe test mode
  
  // Demo Settings
  static const bool showDemoWarnings = false; // Disabled since using real Stripe
  static const String demoMessage = "This is a demonstration app. No real payments are processed.";
  
  // Currency Settings
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  
  // Stripe Configuration (Test Keys)
  static const String stripePublishableKeyTest = 'pk_test_51RjcyQ07HVXoMHga8o8FFCDqIZjiEKL5kOAXbxeqmn1iaWaX6GuLuLVUuCnjSAf5ppNV8sWJAEMIgclkkYSrxbMR00IA2oGpqY';
  static const String stripeSecretKeyTest = 'sk_test_51RjcyQ07HVXoMHgavKuEIeR1o9VZHlH5t2Rv5FKx9F6F7bG7lbyCoHnxsYdpv2APzXYqWEl2tgV6ChHOJilKf0ku00naGYT4MK';
  
  // Stripe Configuration (Live Keys - Only use when ready for production)
  static const String stripePublishableKeyLive = 'pk_live_your_live_key_here';
  static const String stripeSecretKeyLive = 'sk_live_your_live_key_here';
  
  // Get current stripe keys based on mode
  static String get stripePublishableKey {
    if (isDemoMode) return ''; // No keys needed for demo
    return isDevelopment ? stripePublishableKeyTest : stripePublishableKeyLive;
  }
  
  static String get stripeSecretKey {
    if (isDemoMode) return ''; // No keys needed for demo
    return isDevelopment ? stripeSecretKeyTest : stripeSecretKeyLive;
  }
  
  // Demo payment simulation settings
  static const Duration demoPaymentDelay = Duration(seconds: 2);
  static const double demoPaymentSuccessRate = 1.0; // 100% success rate for demo
}

enum PaymentMode {
  demo,
  stripeTest,
  stripeLive,
}
