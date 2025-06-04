class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String image;
  final String description;
  final int quantity;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'quantity': quantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }
}

final List<String> promoImages = [
  'assets/images/smartphons/16pro.jpg',
  'assets/images/labtops/mac.jpg',
  'assets/images/consols/xbox.jpg',
  'assets/images/smartphons/s25.jpg',
  'assets/images/smartwatch/smart-1.jpg',
  'assets/images/consols/full_ps5.jpg',
];

final List<Product> featuredProducts = [
  Product(
    id: 1,
    name: "Iphone 16 Pro",
    price: 65000,
    category: "smartphones",
    image: "assets/images/smartphons/16pro.jpg",
    description:
        "iPhone 16 Pro offers top-tier performance, advanced camera system, and a sleek design. Perfect for professionals and tech enthusiasts.",
    quantity: 10,
  ),
  Product(
    id: 2,
    name: "Macbook Pro",
    price: 120000,
    category: "laptops",
    image: "assets/images/labtops/mac.jpg",
    description:
        "MacBook Pro delivers exceptional power, Retina display, and the M-series chip for creative professionals and developers.",
    quantity: 8,
  ),
  Product(
    id: 3,
    name: "Playstation 5",
    price: 39999,
    category: "consols",
    image: "assets/images/consols/ps5.jpg",
    description:
        "PlayStation 5 brings ultra-fast loading, stunning graphics, and immersive gaming experience with DualSense controller.",
    quantity: 15,
  ),
  Product(
    id: 4,
    name: "Headphones-1",
    price: 4999,
    category: "headphones",
    image: "assets/images/headphones/head-1.jpg",
    description:
        "Headphones-1 provides crystal-clear sound with deep bass and noise cancellation for everyday use.",
    quantity: 25,
  ),
  Product(
    id: 5,
    name: "Dell Inspiron",
    price: 60000,
    category: "laptops",
    image: "assets/images/labtops/dell.jpg",
    description:
        "Dell Inspiron is a reliable and affordable laptop for students and professionals with great performance and battery life.",
    quantity: 12,
  ),
  Product(
    id: 6,
    name: "Samsung Z-Fold",
    price: 90000,
    category: "smartphones",
    image: "assets/images/smartphons/z-fold.jpg",
    description:
        "Samsung Z-Fold offers a foldable design, high-end specs, and multitasking capabilities for tech lovers.",
    quantity: 7,
  ),
];

final List<Product> newArrivals = [
  Product(
    id: 7,
    name: "Lenovo ThinkPad",
    price: 20000,
    category: "laptops",
    image: "assets/images/labtops/lenovo-1.jpg",
    description:
        "Lenovo ThinkPad is built for business, offering durability, powerful performance, and great keyboard comfort.",
    quantity: 10,
  ),
  Product(
    id: 8,
    name: "Samsung S25 Ultra",
    price: 60000,
    category: "smartphones",
    image: "assets/images/smartphons/s25.jpg",
    description:
        "Samsung S25 Ultra features a stunning display, powerful camera, and smooth performance for premium users.",
    quantity: 9,
  ),
  Product(
    id: 9,
    name: "Apple Watch",
    price: 59999,
    category: "smartwatch",
    image: "assets/images/smartwatch/smart-1.jpg",
    description:
        "Apple Watch keeps you connected, tracks your health, and complements your Apple ecosystem seamlessly.",
    quantity: 18,
  ),
  Product(
    id: 25,
    name: "OPPO Reno 8",
    price: 15000,
    category: "smartphones",
    image: "assets/images/smartphons/oppo.jpg",
    description:
        "OPPO Reno 8 is a stylish and budget-friendly phone offering solid performance and good camera quality.",
    quantity: 20,
  ),
  Product(
    id: 26,
    name: "Apple Watch Series 7",
    price: 59999,
    category: "smartwatch",
    image: "assets/images/smartwatch/smart-2.jpg",
    description:
        "Apple Watch Series 7 has a larger screen, faster charging, and enhanced fitness tracking features.",
    quantity: 14,
  ),
];

final List<String> categories = [
  "All",
  "consols",
  "headphones",
  "laptops",
  "smartphones",
  "smartwatch",
];

final List<Product> allProducts = [
  ...featuredProducts,
  ...newArrivals,
  Product(
    id: 10,
    name: "Full Package Playstation 5",
    price: 39999,
    category: "consols",
    image: "assets/images/consols/full_ps5.jpg",
    description:
        "The latest Full Package Playstation 5 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 11,
    name: "Nintendo Switch",
    price: 29999,
    category: "consols",
    image: "assets/images/consols/nintendo.jpg",
    description: "The latest Nintendo Switch with the latest features",
    quantity: 10,
  ),
  Product(
    id: 12,
    name: "Playstation 4",
    price: 29999,
    category: "consols",
    image: "assets/images/consols/ps4.jpg",
    description: "The latest Playstation 4 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 13,
    name: "Xbox Series X",
    price: 39999,
    category: "consols",
    image: "assets/images/consols/xbox.jpg",
    description: "The latest Xbox Series X with the latest features",
    quantity: 10,
  ),
  Product(
    id: 14,
    name: "Xbox Series S",
    price: 29999,
    category: "consols",
    image: "assets/images/consols/xboxs.jpg",
    description: "The latest Xbox Series S with the latest features",
    quantity: 10,
  ),
  Product(
    id: 15,
    name: "Headphones-2",
    price: 4999,
    category: "headphones",
    image: "assets/images/headphones/head-2.jpg",
    description: "The latest Headphones-2 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 16,
    name: "Headphones-3",
    price: 4999,
    category: "headphones",
    image: "assets/images/headphones/head-3.jpg",
    description: "The latest Headphones-3 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 17,
    name: "Headphones-4",
    price: 4999,
    category: "headphones",
    image: "assets/images/headphones/head-4.jpg",
    description: "The latest Headphones-4 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 18,
    name: "Headphones-5",
    price: 4999,
    category: "headphones",
    image: "assets/images/headphones/head-5.jpg",
    description: "The latest Headphones-5 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 19,
    name: "Headphones-6",
    price: 4999,
    category: "headphones",
    image: "assets/images/headphones/head-6.jpg",
    description: "The latest Headphones-6 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 20,
    name: "Dell Laptop",
    price: 4999,
    category: "laptops",
    image: "assets/images/labtops/dell-1.jpg",
    description: "The latest Dell Laptop with the latest features",
    quantity: 10,
  ),
  Product(
    id: 21,
    name: "HP Laptop",
    price: 4999,
    category: "laptops",
    image: "assets/images/labtops/hp.jpg",
    description: "The latest HP Laptop with the latest features",
    quantity: 10,
  ),
  Product(
    id: 22,
    name: "Lenovo IdeaPad",
    price: 4999,
    category: "laptops",
    image: "assets/images/labtops/lenovo.jpg",
    description: "The latest Lenovo IdeaPad with the latest features",
    quantity: 10,
  ),
  Product(
    id: 23,
    name: "Iphone XS Max",
    price: 30000,
    category: "smartphones",
    image: "assets/images/smartphons/xs-max.jpg",
    description: "The latest Iphone XS Max with the latest features",
    quantity: 10,
  ),
  Product(
    id: 24,
    name: "Samsung A54",
    price: 10000,
    category: "smartphones",
    image: "assets/images/smartphons/a54.jpg",
    description: "The latest Samsung A54 with the latest features",
    quantity: 10,
  ),

  Product(
    id: 27,
    name: "Apple Watch Series 8",
    price: 59999,
    category: "smartwatch",
    image: "assets/images/smartwatch/smart-3.jpg",
    description: "The latest Apple Watch Series 8 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 28,
    name: "Apple Watch Series 9",
    price: 59999,
    category: "smartwatch",
    image: "assets/images/smartwatch/smart-4.jpg",
    description: "The latest Apple Watch Series 9 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 29,
    name: "Apple Watch Series 10",
    price: 59999,
    category: "smartwatch",
    image: "assets/images/smartwatch/smart-5.jpg",
    description: "The latest Apple Watch Series 10 with the latest features",
    quantity: 10,
  ),
  Product(
    id: 30,
    name: "Apple Watch Series 11",
    price: 59999,
    category: "smartwatch",
    image: "assets/images/smartwatch/smart-6.jpg",
    description: "The latest Apple Watch Series 11 with the latest features",
    quantity: 10,
  ),
];
