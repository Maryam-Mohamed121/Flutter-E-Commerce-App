import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../widgets/custom_product.dart';
import '../widgets/custom_category_page.dart';
import '../screens/search_screen.dart';
import '../screens/product_details_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? currentUserName;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final PageController _newArrivalsController = PageController(
    viewportFraction: 0.5,
  );
  Timer? _timer;
  Timer? _newArrivalsTimer;
  int _currentPage = 0;
  int _currentNewArrival = 0;

  @override
  void initState() {
    super.initState();
    getUserName();
    _startAutoScroll();
    _startNewArrivalsScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _newArrivalsTimer?.cancel();
    _pageController.dispose();
    _newArrivalsController.dispose();
    super.dispose();
  }

  Future<void> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserName = prefs.getString('userName') ?? 'Guest';
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < promoImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startNewArrivalsScroll() {
    _newArrivalsTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentNewArrival < newArrivals.length - 1) {
        _currentNewArrival++;
      } else {
        _currentNewArrival = 0;
      }
      _newArrivalsController.animateToPage(
        _currentNewArrival,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mary-Electro-Store',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFF476A88),

        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(allProducts),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg-2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(0xFF476A88),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome, ${currentUserName ?? 'Guest'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Promo slider with PageView
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Most Popular Products',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildPromoSlider(),
              SizedBox(height: 10),

              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildCategoryList(context),

              // Featured Products
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildFeaturedProducts(),

              // New Arrivals
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'New Arrivals',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildNewArrivals(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoSlider() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: promoImages.length,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final product = allProducts.firstWhere(
            (product) => product.image == promoImages[index],
            orElse: () => featuredProducts[0],
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(product: product),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(promoImages[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final icon = _getCategoryIcon(category);

          return GestureDetector(
            onTap: () {
              _navigateToCategory(context, category);
            },
            child: Container(
              width: 150,
              height: 100,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Color(0xFF476A88),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.category;
      case 'consols':
        return Icons.videogame_asset;
      case 'headphones':
        return Icons.headphones;
      case 'laptops':
        return Icons.laptop_mac;
      case 'smartphones':
        return Icons.smartphone;
      case 'smartwatch':
        return Icons.watch;
      default:
        return Icons.category;
    }
  }

  Widget _buildFeaturedProducts() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: featuredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(product: featuredProducts[index]);
      },
    );
  }

  Widget _buildNewArrivals() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _newArrivalsController,
        onPageChanged: (index) {
          setState(() {
            _currentNewArrival = index;
          });
        },
        itemCount: newArrivals.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: ProductCard(product: newArrivals[index]),
          );
        },
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    List<Product> filteredProducts = category.toLowerCase() == 'all'
        ? allProducts
        : allProducts
              .where((p) => p.category.toLowerCase() == category.toLowerCase())
              .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsPage(
          category: category,
          products: filteredProducts,
        ),
      ),
    );
  }
}
