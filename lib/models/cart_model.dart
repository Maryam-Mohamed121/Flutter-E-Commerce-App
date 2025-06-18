class CartItem {
  final int id;
  final String name;
  final double price;
  final String image;
  int quantity;
  final int maxQuantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.maxQuantity,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'image': image,
    'quantity': quantity,
    'maxQuantity': maxQuantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'],
    name: map['name'],
    price: map['price'],
    image: map['image'],
    quantity: map['quantity'],
    maxQuantity: map['maxQuantity'] ?? 50,
  );
}
