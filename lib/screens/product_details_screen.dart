import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import 'cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  ProductDetailsScreen({required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;
  bool isFavorite = false;
  bool isInCart = false;
  int cartQuantity = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('email');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to use cart and favorites')),
      );
    }
    setState(() {
      _currentUserId = userId;
    });
    _checkCartStatus();
    _checkFavoriteStatus();
  }

  Future<void> _checkCartStatus() async {
    if (_currentUserId == null) return;

    final cartItems = await getCartItems();
    final cartItem = cartItems.firstWhere(
      (item) => item.id == widget.product.id,
      orElse: () =>
          CartItem(id: -1, name: '', price: 0, image: '', quantity: 0),
    );

    setState(() {
      isInCart = cartItem.id != -1;
      if (isInCart) {
        cartQuantity = cartItem.quantity;
        quantity = cartQuantity;
      }
    });
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

  Future<void> toggleCart() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to add items to cart')),
      );
      return;
    }

    try {
      List<CartItem> cartItems = await getCartItems();

      if (isInCart) {
        // Remove from cart
        cartItems.removeWhere((item) => item.id == widget.product.id);
        await saveCartItems(cartItems);
        setState(() {
          isInCart = false;
          quantity = 1;
        });
      } else {
        // Add to cart
        final newItem = CartItem(
          id: widget.product.id,
          name: widget.product.name,
          price: widget.product.price,
          image: widget.product.image,
          quantity: quantity,
        );

        // Check if item already exists in cart
        final existingItemIndex = cartItems.indexWhere(
          (item) => item.id == widget.product.id,
        );
        if (existingItemIndex != -1) {
          cartItems[existingItemIndex].quantity += quantity;
        } else {
          cartItems.add(newItem);
        }

        await saveCartItems(cartItems);
        setState(() {
          isInCart = true;
          cartQuantity = quantity;
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> updateCartQuantity() async {
    if (!isInCart || _currentUserId == null) return;

    List<CartItem> cartItems = await getCartItems();
    final index = cartItems.indexWhere((item) => item.id == widget.product.id);
    if (index >= 0) {
      cartItems[index].quantity = quantity;
      await saveCartItems(cartItems);
      setState(() {
        cartQuantity = quantity;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? wishlistItems = prefs.getString('wishlist_${_currentUserId}');
    if (wishlistItems != null) {
      final List<Product> items = (jsonDecode(wishlistItems) as List)
          .map((e) => Product.fromMap(e))
          .toList();
      setState(() {
        isFavorite = items.any((item) => item.id == widget.product.id);
      });
    }
  }

  Future<void> toggleFavorite() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login to add favorites')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? wishlistItems = prefs.getString('wishlist_$_currentUserId');
    List<Product> items = [];

    if (wishlistItems != null) {
      items = (jsonDecode(wishlistItems) as List)
          .map((e) => Product.fromMap(e))
          .toList();
    }

    setState(() {
      if (isFavorite) {
        items.removeWhere((item) => item.id == widget.product.id);
      } else {
        items.add(widget.product);
      }
      isFavorite = !isFavorite;
    });

    await prefs.setString(
      'wishlist_$_currentUserId',
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF476A88),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(widget.product.image, fit: BoxFit.contain),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'EGP ${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF476A88),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                              if (isInCart) updateCartQuantity();
                            });
                          }
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            quantity++;
                            if (isInCart) updateCartQuantity();
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Add/Remove from Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart
                            ? Colors.red
                            : Color(0xFF476A88),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        isInCart
                            ? Icons.remove_shopping_cart
                            : Icons.shopping_cart_checkout,
                        color: Colors.white,
                      ),
                      label: Text(
                        isInCart ? 'Remove from Cart' : 'Add to Cart',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: toggleCart,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
