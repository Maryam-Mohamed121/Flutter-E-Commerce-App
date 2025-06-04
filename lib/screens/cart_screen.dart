import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import 'bottomnavbar_screen.dart';
import '../widgets/custom_button.dart';
import 'package:uuid/uuid.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  String? _currentUserId;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadCart();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('email');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login to view your cart')));
    }
    setState(() {
      _currentUserId = userId;
    });
    loadCart();
  }

  Future<List<CartItem>> getCartItems() async {
    if (_currentUserId == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cart_$_currentUserId');
    if (cartData == null) return [];
    try {
      final List decoded = jsonDecode(cartData);
      return decoded.map((item) => CartItem.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCartItems(List<CartItem> items) async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    try {
      final String encoded = jsonEncode(items.map((e) => e.toMap()).toList());
      await prefs.setString('cart_$_currentUserId', encoded);
    } catch (e) {
      return;
    }
  }

  Future<void> _createOrder() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login to place an order')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Create new order
    final order = Order(
      id: _uuid.v4(),
      userId: _currentUserId!,
      items: List.from(_cartItems),
      totalAmount: totalPrice,
      orderDate: DateTime.now(),
      status: 'pending',
    );

    // Get existing orders for this user
    final String? ordersData = prefs.getString('orders_${_currentUserId}');
    List<Order> orders = [];
    if (ordersData != null) {
      orders = (jsonDecode(ordersData) as List)
          .map((order) => Order.fromMap(order))
          .toList();
    }

    // Add new order
    orders.add(order);
    await prefs.setString(
      'orders_${_currentUserId}',
      jsonEncode(orders.map((o) => o.toMap()).toList()),
    );

    // Clear cart
    await saveCartItems([]);
    setState(() {
      _cartItems = [];
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CheckoutScreen()),
    );
  }

  Future<void> loadCart() async {
    if (_currentUserId == null) {
      setState(() {
        _cartItems = [];
      });
      return;
    }

    try {
      final items = await getCartItems();
      setState(() {
        _cartItems = items;
      });
    } catch (e) {
      setState(() {
        _cartItems = [];
      });
    }
  }

  Future<void> updateCart() async {
    try {
      await saveCartItems(_cartItems);
      setState(() {});
    } catch (e) {
      return;
    }
  }

  void increaseQuantity(int index) {
    setState(() {
      _cartItems[index].quantity++;
    });
    updateCart();
  }

  void decreaseQuantity(int index) {
    if (_cartItems[index].quantity > 1) {
      setState(() {
        _cartItems[index].quantity--;
      });
      updateCart();
    }
  }

  void removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    updateCart();
  }

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF476A88),
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Container(
                child: Column(
                  children: [
                    Image.asset('assets/images/empty-cart.jpg'),
                    SizedBox(height: 20),
                    CustomButton(
                      color: Color(0xFF476A88),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavBar(),
                          ),
                        );
                      },
                      text: 'Go to Home',
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (_, index) {
                final item = _cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item.image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${item.price.toStringAsFixed(2)} EGP",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF476A88),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Quantity Controls
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove, size: 20),
                                          onPressed: () =>
                                              decreaseQuantity(index),
                                          padding: EdgeInsets.all(8),
                                          constraints: BoxConstraints(),
                                        ),
                                        Text(
                                          item.quantity.toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add, size: 20),
                                          onPressed: () =>
                                              increaseQuantity(index),
                                          padding: EdgeInsets.all(8),
                                          constraints: BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    onPressed: () => removeItem(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total: ${totalPrice.toStringAsFixed(2)} EGP",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF476A88),
              ),
            ),
            CustomButton(
              onPressed: () {
                if (_cartItems.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Empty Cart',
                          style: TextStyle(
                            color: Color(0xFF476A88),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 50,
                              color: Color(0xFF476A88),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your cart is empty!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please add some products to your cart before checkout.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF476A88)),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckoutScreen()),
                  );
                }
              },
              text: "Checkout",
              color: Color(0xFF476A88),
            ),
          ],
        ),
      ),
    );
  }
}
