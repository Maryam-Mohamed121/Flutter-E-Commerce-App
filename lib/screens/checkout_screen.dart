import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bottomnavbar_screen.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'Cash on Delivery';
  final double shippingFee = 50.0;
  double totalAmount = 0.0;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userAddress;

  // Add controllers for card details
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCartTotal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Guest';
      userEmail = prefs.getString('email') ?? '';
      userPhone = prefs.getString('phoneNumber') ?? '';
      userAddress = prefs.getString('address') ?? '';

      _nameController.text = userName ?? '';
      _phoneController.text = userPhone ?? '';
      _addressController.text = userAddress ?? '';
    });
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = userName ?? '';
        _phoneController.text = userPhone ?? '';
        _addressController.text = userAddress ?? '';
      }
    });
  }

  void _saveShippingDetails() {
    setState(() {
      userName = _nameController.text;
      userPhone = _phoneController.text;
      userAddress = _addressController.text;
      _isEditing = false;
    });
  }

  Future<void> _loadCartTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('email');
    if (userId == null) return;

    final String? cartData = prefs.getString('cart_$userId');
    if (cartData != null) {
      final List decoded = jsonDecode(cartData);
      final cartItems = decoded.map((item) => CartItem.fromMap(item)).toList();
      setState(() {
        totalAmount = cartItems.fold(
          0,
          (sum, item) => sum + item.price * item.quantity,
        );
      });
    }
  }

  void _showThankYouDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('email');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login to place an order')));
      return print("login first");
    }


    final String? cartData = prefs.getString('cart_$userId');
    if (cartData == null) return;

    List<CartItem> cartItems = (jsonDecode(cartData) as List)
        .map((item) => CartItem.fromMap(item))
        .toList();


    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      items: cartItems,
      totalAmount: totalAmount + shippingFee,
      orderDate: DateTime.now(),

    );


    final String? ordersData = prefs.getString('orders_$userId');
    List<Order> orders = [];
    if (ordersData != null) {
      orders = (jsonDecode(ordersData) as List)
          .map((order) => Order.fromMap(order))
          .toList();
    }


    orders.add(newOrder);


    await prefs.setString(
      'orders_$userId',
      jsonEncode(orders.map((e) => e.toMap()).toList()),
    );

    // Clear cart
    await prefs.remove('cart_$userId');

    // Show thank you dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Thank You!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Your order has been placed successfully.',
            style: TextStyle(fontSize: 20, color: Color(0xFF476A88)),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
              onPressed: () {
                // Pop all screens until we reach the home screen
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Navigate to the home screen with a fresh instance
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNavBar()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Add method to show card details dialog
  void _showCardDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Card Details',
            style: TextStyle(
              color: Color(0xFF476A88),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _cardNameController,
                  decoration: InputDecoration(
                    labelText: 'Name on Card',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _expiryController,
                        decoration: InputDecoration(
                          labelText: 'Expiry (MM/YY)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        maxLength: 5,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectedPaymentMethod = 'Cash on Delivery';
                });
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Color(0xFF476A88),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // Validate card name
                if (_cardNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter name on card'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate card number
                if (_cardNumberController.text.length != 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Card number must be 16 digits'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate expiry date
                if (!RegExp(
                  r'^(0[1-9]|1[0-2])/([0-9]{2})$',
                ).hasMatch(_expiryController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid expiry date format (MM/YY)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate CVV
                if (_cvvController.text.length != 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('CVV must be 3 digits'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = totalAmount + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF476A88),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Shipping Details Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Shipping Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditing ? Icons.close : Icons.edit,
                                ),
                                onPressed: _toggleEditing,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          if (_isEditing) ...[
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Shipping Address',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _saveShippingDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF476A88),
                                minimumSize: Size(double.infinity, 45),
                              ),
                              child: Text(
                                'Save Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ] else ...[
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text(userName ?? 'Guest'),
                              subtitle: Text(userEmail ?? ''),
                            ),
                            ListTile(
                              leading: Icon(Icons.phone),
                              title: Text(userPhone ?? 'No phone number'),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_on),
                              title: Text(userAddress ?? 'No address'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Payment Method Card
                  Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.payment),
                          title: Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        RadioListTile(
                          title: Text('Credit/Debit Card'),
                          value: 'Credit Card',
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                            _showCardDetailsDialog();
                          },
                        ),
                        RadioListTile(
                          title: Text('Cash on Delivery'),
                          value: 'Cash on Delivery',
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Price Details Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order Amount',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${totalAmount.toStringAsFixed(2)} EGP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shipping', style: TextStyle(fontSize: 16)),
                              Text(
                                '${shippingFee.toStringAsFixed(2)} EGP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${grandTotal.toStringAsFixed(2)} EGP',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF476A88),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showThankYouDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF476A88),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
