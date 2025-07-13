import 'payment_method.dart';
import 'shipping_address.dart';

enum UserRole {
  customer,
  admin,
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final List<ShippingAddress> shippingAddresses;
  final String? defaultPaymentMethodId;
  final String? defaultShippingAddressId;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.addresses = const [],
    this.paymentMethods = const [],
    this.shippingAddresses = const [],
    this.defaultPaymentMethodId,
    this.defaultShippingAddressId,
    this.role = UserRole.customer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      addresses: (json['addresses'] as List?)
          ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      paymentMethods: (json['paymentMethods'] as List?)
          ?.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      shippingAddresses: (json['shippingAddresses'] as List?)
          ?.map((e) => ShippingAddress.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      defaultPaymentMethodId: json['defaultPaymentMethodId'] as String?,
      defaultShippingAddressId: json['defaultShippingAddressId'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role'] ?? 'customer'}',
        orElse: () => UserRole.customer,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
      'shippingAddresses': shippingAddresses.map((e) => e.toJson()).toList(),
      'defaultPaymentMethodId': defaultPaymentMethodId,
      'defaultShippingAddressId': defaultShippingAddressId,
      'role': role.toString().split('.').last,
    };
  }

  // Utility methods
  PaymentMethod? get defaultPaymentMethod {
    if (defaultPaymentMethodId == null) return null;
    try {
      return paymentMethods.firstWhere((pm) => pm.id == defaultPaymentMethodId);
    } catch (e) {
      return null;
    }
  }

  ShippingAddress? get defaultShippingAddress {
    if (defaultShippingAddressId == null) return null;
    try {
      return shippingAddresses.firstWhere((sa) => sa.id == defaultShippingAddressId);
    } catch (e) {
      return null;
    }
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
    List<ShippingAddress>? shippingAddresses,
    String? defaultPaymentMethodId,
    String? defaultShippingAddressId,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      shippingAddresses: shippingAddresses ?? this.shippingAddresses,
      defaultPaymentMethodId: defaultPaymentMethodId ?? this.defaultPaymentMethodId,
      defaultShippingAddressId: defaultShippingAddressId ?? this.defaultShippingAddressId,
      role: role ?? this.role,
    );
  }
}

class Address {
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
    };
  }
}
