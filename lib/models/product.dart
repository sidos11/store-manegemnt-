class Product {
  final int? id;
  final String name;
  final double price;
  final int quantity;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  // JSON → Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }

  // Product → JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}