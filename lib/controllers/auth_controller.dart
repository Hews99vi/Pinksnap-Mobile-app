import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/firebase_auth_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  
  User? get currentUser => _currentUser.value;
  Rx<User?> get currentUserRx => _currentUser; // Expose the reactive user
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isAdmin => _currentUser.value?.role == UserRole.admin;
  
  final _storage = const FlutterSecureStorage();
  
  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
  }
  
  void _initializeAuthListener() {
    // Listen to Firebase auth state changes
    FirebaseAuthService.authStateChanges.listen((firebase_auth.User? firebaseUser) async {
      debugPrint('=== AUTH STATE CHANGE ===');
      debugPrint('Firebase user: ${firebaseUser?.email ?? 'None'}');
      debugPrint('Firebase user UID: ${firebaseUser?.uid ?? 'None'}');
      
      if (firebaseUser != null) {
        // User is signed in, get user data from Firestore
        try {
          // Refresh token to ensure we have latest custom claims
          await firebaseUser.getIdToken(true);
          
          // Debug: Log admin claim status
          final idTokenResult = await firebaseUser.getIdTokenResult(true);
          debugPrint('🔐 Admin claim in auth listener: ${idTokenResult.claims?['admin']}');
          
          User? userData = await FirebaseAuthService.getUserData(firebaseUser.uid);
          if (userData != null) {
            debugPrint('Setting current user: ${userData.email} (ID: ${userData.id})');
            debugPrint('User role from Firestore: ${userData.role}');
            _currentUser.value = userData;
            await _storage.write(key: 'user_data', value: userData.toJson().toString());
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
        }
      } else {
        // User is signed out
        debugPrint('User signed out - clearing current user data');
        _currentUser.value = null;
        await _storage.delete(key: 'user_data');
      }
      debugPrint('Current user after change: ${_currentUser.value?.email ?? 'None'}');
      debugPrint('========================');
    });
  }
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      
      User? user = await FirebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        _currentUser.value = user;
        
        // Extra verification: Force token refresh and check admin claim
        final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final token = await firebaseUser.getIdTokenResult(true); // Force refresh
          debugPrint('🔐 POST-LOGIN VERIFICATION:');
          debugPrint('   Email: ${firebaseUser.email}');
          debugPrint('   UID: ${firebaseUser.uid}');
          debugPrint('   Admin claim: ${token.claims?['admin']}');
          if (token.claims?['admin'] != true) {
            debugPrint('   ⚠️  WARNING: Admin claim is NOT set! Run set-admin-claim.js script.');
          } else {
            debugPrint('   ✅ Admin claim verified successfully!');
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      Get.snackbar('Login Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> register(String name, String email, String password, {UserRole role = UserRole.customer, String? phoneNumber}) async {
    try {
      _isLoading.value = true;
      
      User? user = await FirebaseAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );
      
      if (user != null) {
        _currentUser.value = user;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      Get.snackbar('Registration Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await FirebaseAuthService.signOut();
      _currentUser.value = null;
    } catch (e) {
      debugPrint('Logout error: $e');
      Get.snackbar('Logout Error', e.toString().replaceAll('Exception: ', ''));
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuthService.resetPassword(email);
      Get.snackbar('Success', 'Password reset email sent to $email');
      return true;
    } catch (e) {
      debugPrint('Reset password error: $e');
      Get.snackbar('Reset Password Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
  
  Future<bool> updateProfile(User updatedUser) async {
    try {
      _isLoading.value = true;
      
      await FirebaseAuthService.updateUserData(updatedUser);
      _currentUser.value = updatedUser;
      
      Get.snackbar('Success', 'Profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      Get.snackbar('Update Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Force refresh ID token to get latest custom claims (e.g., admin claim)
  /// Call this after setting admin claim via backend script
  Future<void> forceTokenRefresh() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        debugPrint('🔄 Forcing token refresh...');
        final token = await firebaseUser.getIdTokenResult(true); // Force refresh
        debugPrint('🔐 FORCE REFRESH RESULT:');
        debugPrint('   Email: ${firebaseUser.email}');
        debugPrint('   Admin claim: ${token.claims?['admin']}');
        
        if (token.claims?['admin'] == true) {
          debugPrint('   ✅ Admin claim verified!');
        } else {
          debugPrint('   ⚠️  Admin claim is NULL or FALSE');
          debugPrint('   → Run: node set-admin-claim.js ${firebaseUser.uid}');
          debugPrint('   → Then sign out and sign in again');
        }
      } else {
        debugPrint('⚠️  No user logged in - cannot refresh token');
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }
  }
}
