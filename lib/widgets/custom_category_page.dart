import 'package:flutter/material.dart';
import '../models/product.dart';
import 'custom_product.dart';

class CategoryProductsPage extends StatefulWidget {
  final String category;
  final List<Product> products;

  const CategoryProductsPage({required this.category, required this.products});

  @override
  _CategoryProductsPageState createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Product> _sortedProducts = [];
  String _currentSort = 'Default';
  @override
  void initState() {
    super.initState();
    _sortedProducts = List.from(widget.products);
  }

  void _sortProducts(String sortType) {
    setState(() {
      _currentSort = sortType;
      switch (sortType) {
        case 'Price: Low to High':
          _sortedProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price: High to Low':
          _sortedProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Name: A to Z':
          _sortedProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Name: Z to A':
          _sortedProducts.sort((a, b) => b.name.compareTo(a.name));
          break;
        default:
          _sortedProducts = List.from(widget.products);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF476A88),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: _sortProducts,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'Default', child: Text('Default')),
              PopupMenuItem(
                value: 'Price: Low to High',
                child: Text('Price: Low to High'),
              ),
              PopupMenuItem(
                value: 'Price: High to Low',
                child: Text('Price: High to Low'),
              ),
              PopupMenuItem(value: 'Name: A to Z', child: Text('Name: A to Z')),
              PopupMenuItem(value: 'Name: Z to A', child: Text('Name: Z to A')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _sortedProducts.isEmpty
                  ? Center(child: Text('No products in this category'))
                  : GridView.builder(
                      padding: EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _sortedProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _sortedProducts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
