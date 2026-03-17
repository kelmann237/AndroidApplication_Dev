import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════
//  ENTRY POINT
// ════════════════════════════════════════════════════════════════

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  MODEL
// ════════════════════════════════════════════════════════════════

class Product {
  final int id;
  final String name;
  final double price;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}

// ════════════════════════════════════════════════════════════════
//  VIEWMODEL  (simple state — no external package needed)
// ════════════════════════════════════════════════════════════════

class CartViewModel extends ChangeNotifier {
  // Hardcoded product list
  final List<Product> products = const [
    Product(id: 1, name: 'Wireless Headphones', price: 79.99, description: 'Noise-cancelling, 30hr battery life.'),
    Product(id: 2, name: 'Mechanical Keyboard',  price: 49.99, description: 'RGB backlit, tactile switches.'),
    Product(id: 3, name: 'USB-C Hub',            price: 34.99, description: '7-in-1, 4K HDMI, 100W PD charging.'),
    Product(id: 4, name: 'Webcam 1080p',          price: 59.99, description: 'Auto-focus with built-in mic.'),
    Product(id: 5, name: 'Mouse Pad XL',          price: 19.99, description: 'Stitched edges, non-slip base.'),
  ];

  final List<int> _cartIds = [];

  int get cartCount => _cartIds.length;

  bool isInCart(int productId) => _cartIds.contains(productId);

  void addToCart(int productId) {
    if (!_cartIds.contains(productId)) {
      _cartIds.add(productId);
      notifyListeners();
    }
  }
}

// ════════════════════════════════════════════════════════════════
//  SCREEN 1 — ProductListScreen
// ════════════════════════════════════════════════════════════════

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // ViewModel lives here and is passed down to the detail screen
  final CartViewModel _viewModel = CartViewModel();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Products'),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            actions: [
              // Cart badge
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 28),
                    if (_viewModel.cartCount > 0)
                      Positioned(
                        top: 6,
                        right: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${_viewModel.cartCount}',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _viewModel.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = _viewModel.products[index];
              final inCart = _viewModel.isInCart(product.id);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10,
                  ),
                  // Number avatar
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Text(
                      '${product.id}',
                      style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  // Green check if already in cart, arrow otherwise
                  trailing: inCart
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to detail screen, pass viewModel + product id
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: product.id,
                          viewModel: _viewModel,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SCREEN 2 — ProductDetailScreen
// ════════════════════════════════════════════════════════════════

class ProductDetailScreen extends StatelessWidget {
  final int productId;
  final CartViewModel viewModel;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        // Look up the product by ID from the ViewModel
        final product = viewModel.products.firstWhere((p) => p.id == productId);
        final inCart = viewModel.isInCart(product.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Product card ──────────────────────────────
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Add to Cart button ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    // Disable button once product is in cart
                    onPressed: inCart
                        ? null
                        : () {
                            viewModel.addToCart(product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    icon: Icon(inCart ? Icons.check : Icons.add_shopping_cart),
                    label: Text(
                      inCart ? 'Added to Cart' : 'Add to Cart',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          inCart ? Colors.grey.shade400 : Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}