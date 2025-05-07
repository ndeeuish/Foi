class StripePayment {
  final String paymentIntentId;
  final double amount;
  final String status;
  final String? cardLast4;
  final String? cardBrand;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StripePayment({
    required this.paymentIntentId,
    required this.amount,
    required this.status,
    this.cardLast4,
    this.cardBrand,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory StripePayment.fromJson(Map<String, dynamic> json) {
    return StripePayment(
      paymentIntentId: json['paymentIntentId'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      cardLast4: json['cardLast4'],
      cardBrand: json['cardBrand'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentIntentId': paymentIntentId,
      'amount': amount,
      'status': status,
      'cardLast4': cardLast4,
      'cardBrand': cardBrand,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  StripePayment copyWith({
    String? paymentIntentId,
    double? amount,
    String? status,
    String? cardLast4,
    String? cardBrand,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StripePayment(
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardBrand: cardBrand ?? this.cardBrand,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 