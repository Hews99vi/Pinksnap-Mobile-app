class PaymentMethod {
  final String id;
  final String type; // 'card', 'stripe', 'paypal', etc.
  final String last4; // Last 4 digits for cards
  final String brand; // 'visa', 'mastercard', etc.
  final String expiryMonth;
  final String expiryYear;
  final String holderName;
  final bool isDefault;
  final String? stripePaymentMethodId;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.holderName,
    this.isDefault = false,
    this.stripePaymentMethodId,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: json['type'] as String,
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      expiryMonth: json['expiryMonth'] as String,
      expiryYear: json['expiryYear'] as String,
      holderName: json['holderName'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      stripePaymentMethodId: json['stripePaymentMethodId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'brand': brand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'holderName': holderName,
      'isDefault': isDefault,
      'stripePaymentMethodId': stripePaymentMethodId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayName {
    return '$brand •••• $last4';
  }

  String get expiryDisplay {
    return '$expiryMonth/$expiryYear';
  }

  PaymentMethod copyWith({
    String? id,
    String? type,
    String? last4,
    String? brand,
    String? expiryMonth,
    String? expiryYear,
    String? holderName,
    bool? isDefault,
    String? stripePaymentMethodId,
    DateTime? createdAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      holderName: holderName ?? this.holderName,
      isDefault: isDefault ?? this.isDefault,
      stripePaymentMethodId: stripePaymentMethodId ?? this.stripePaymentMethodId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
