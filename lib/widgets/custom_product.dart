import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart';
import '../models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isInCart = false;
  bool isInWishlist = false;
  int quantity = 1;
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
    _checkWishlistStatus();
    _checkCartStatus();
  }

  Future<void> _checkCartStatus() async {
    if (_currentUserId == null) return;

    final cartItems = await getCartItems();
    setState(() {
      isInCart = cartItems.any((item) => item.id == widget.product.id);
    });
  }

  Future<void> _checkWishlistStatus() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? wishlist = prefs.getString('wishlist_$_currentUserId');
    if (wishlist != null) {
      try {
        List<Product> items = (jsonDecode(wishlist) as List)
            .map((e) => Product.fromMap(e))
            .toList();

        setState(() {
          isInWishlist = items.any((p) => p.id == widget.product.id);
        });
      } catch (e) {
        return;
      }
    }
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

  void toggleCart(Product product) async {
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
        cartItems.removeWhere((item) => item.id == product.id);
        await saveCartItems(cartItems);
        setState(() {
          isInCart = false;
        });
      } else {
        final newItem = CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          image: product.image,
          quantity: 1,
          maxQuantity: product.quantity,
        );

        final existingItemIndex = cartItems.indexWhere(
          (item) => item.id == product.id,
        );
        if (existingItemIndex != -1) {
          cartItems[existingItemIndex].quantity += 1;
        } else {
          cartItems.add(newItem);
        }
        await saveCartItems(cartItems);
        setState(() {
          isInCart = true;
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> toggleWishlist() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login to add favorites')));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? wishlist = prefs.getString('wishlist_$_currentUserId');
      List<Product> items = [];

      if (wishlist != null) {
        items = (jsonDecode(wishlist) as List)
            .map((e) => Product.fromMap(e))
            .toList();
      }

      final index = items.indexWhere((p) => p.id == widget.product.id);
      if (index >= 0) {
        items.removeAt(index);
        setState(() {
          isInWishlist = false;
        });
      } else {
        items.add(widget.product);
        setState(() {
          isInWishlist = true;
        });
      }

      await prefs.setString(
        'wishlist_$_currentUserId',
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorites. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: widget.product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage(widget.product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${widget.product.price.toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          color: Color(0xFF476A88),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: isInCart
                            ? Icon(
                                Icons.shopping_cart,
                                color: Color(0xFF476A88),
                              )
                            : Icon(
                                Icons.shopping_cart_outlined,
                                color: Color(0xFF476A88),
                              ),
                        onPressed: () => toggleCart(widget.product),
                      ),
                      IconButton(
                        icon: isInWishlist
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(
                                Icons.favorite_border_outlined,
                                color: Colors.red,
                              ),
                        onPressed: toggleWishlist,
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
  }
}
