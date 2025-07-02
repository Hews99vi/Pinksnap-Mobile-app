import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isAdmin => _currentUser.value?.role == UserRole.admin;
  
  final _storage = const FlutterSecureStorage();
  
  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }
  
  Future<void> _loadUserFromStorage() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null) {
        // In a real app, you'd parse the JSON and create a User object
        // For demo purposes, we'll create a sample user
        _setCurrentUser(await _getSampleUser());
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }
  
  Future<User> _getSampleUser() async {
    // For demo purposes, create a sample admin user
    // In a real app, this would come from your backend
    return User(
      id: '1',
      name: 'Admin User',
      email: 'admin@pinksnap.com',
      phoneNumber: '+1234567890',
      role: UserRole.admin,
    );
  }
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      
      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));
      
      // Demo admin credentials
      if (email == 'admin@pinksnap.com' && password == 'admin123') {
        final adminUser = User(
          id: '1',
          name: 'Admin User',
          email: email,
          phoneNumber: '+1234567890',
          role: UserRole.admin,
        );
        await _setCurrentUser(adminUser);
        return true;
      }
      
      // Demo regular user credentials
      if (email == 'user@pinksnap.com' && password == 'user123') {
        final regularUser = User(
          id: '2',
          name: 'Regular User',
          email: email,
          phoneNumber: '+0987654321',
          role: UserRole.customer,
        );
        await _setCurrentUser(regularUser);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> _setCurrentUser(User user) async {
    _currentUser.value = user;
    await _storage.write(key: 'user_data', value: user.toJson().toString());
  }
  
  Future<void> logout() async {
    _currentUser.value = null;
    await _storage.delete(key: 'user_data');
  }
  
  Future<bool> register(String name, String email, String password, {UserRole role = UserRole.customer}) async {
    try {
      _isLoading.value = true;
      
      // Simulate registration process
      await Future.delayed(const Duration(seconds: 2));
      
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
      );
      
      await _setCurrentUser(newUser);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
