// import 'package:flutter/material.dart';
import 'cart_model.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,

  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toMap()).toList(),
    'totalAmount': totalAmount,
    'orderDate': orderDate.toIso8601String(),

  };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
    id: map['id'],
    userId: map['userId'],
    items: (map['items'] as List)
        .map((item) => CartItem.fromMap(item))
        .toList(),
    totalAmount: map['totalAmount'],
    orderDate: DateTime.parse(map['orderDate']),

  );
}
