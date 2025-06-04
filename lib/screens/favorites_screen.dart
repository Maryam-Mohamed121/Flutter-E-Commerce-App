import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _wishlistItems = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('email');
    setState(() {
      _currentUserId = userId;
    });
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    if (_currentUserId == null) {
      setState(() {
        _wishlistItems = [];
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? wishlistItems = prefs.getString('wishlist_$_currentUserId');

    if (wishlistItems != null) {
      try {
        final List<Product> items = (jsonDecode(wishlistItems) as List)
            .map((e) => Product.fromMap(e))
            .toList();
        setState(() {
          _wishlistItems = items;
        });
      } catch (e) {
        setState(() {
          _wishlistItems = [];
        });
      }
    } else {
      setState(() {
        _wishlistItems = [];
      });
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    if (_currentUserId == null) return;

    try {
      setState(() {
        _wishlistItems.removeWhere((p) => p.id == productId);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'wishlist_$_currentUserId',
        jsonEncode(_wishlistItems.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing from favorites. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF476A88),
      ),
      body: _currentUserId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 150, color: Color(0xFF476A88)),
                  SizedBox(height: 16),
                  Text(
                    "Please login to view your favorites",
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.heart_broken_outlined,
                    size: 150,
                    color: Color(0xFF476A88),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No favorite items yet",
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _wishlistItems.length,
              itemBuilder: (context, index) {
                final product = _wishlistItems[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              product.image,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 28,
                              ),
                              onPressed: () => removeFromWishlist(product.id),
                            ),
                          ),
                        ],
                      ),
                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${product.price.toStringAsFixed(2)} EGP',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF476A88),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
