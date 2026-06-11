class Sale {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final double totalPrice;
  final String date;

  Sale({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': date,
    };
  }
}
