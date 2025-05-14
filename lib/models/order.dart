class Order {
  final String id;
  final String userId;
  final String receipt;
  final String paymentStatus;
  final String timestamp;
  final String totalItems;
  final String totalPrice;
  final String deliveryAddress;

  Order({
    required this.id,
    required this.userId,
    required this.receipt,
    required this.paymentStatus,
    required this.timestamp,
    required this.totalItems,
    required this.totalPrice,
    required this.deliveryAddress,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      userId: map['userId'] as String,
      receipt: map['receipt'] as String,
      paymentStatus: map['paymentStatus'] as String,
      timestamp: map['timestamp'] as String,
      totalItems: map['totalItems'] as String,
      totalPrice: map['totalPrice'] as String,
      deliveryAddress: map['deliveryAddress'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'receipt': receipt,
      'paymentStatus': paymentStatus,
      'timestamp': timestamp,
      'totalItems': totalItems,
      'totalPrice': totalPrice,
      'deliveryAddress': deliveryAddress,
    };
  }
} 