import 'package:flutter/material.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/widgets/payment_section.dart';
import 'package:myapp/widgets/product_card.dart';
import 'package:myapp/widgets/cart_page.dart';

class HomePage extends StatefulWidget {
  final String title;
  
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Alface',
      description: 'Unidade com aproximadamente 300g de alface americana',
      price: 1.99,

    ),
    Product(
      id: '2',
      name: 'Repolho',
      description: 'Unidade de repolho verde',
      price: 3.99,

    ),
    Product(
      id: '3',
      name: 'Cenoura',
      description: 'Cenoura orgânica vendida em pacotes de 1kg',
      price: 3.99,
 
    ),
  ];
  final List<Product> _cartItems = [];

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartItems.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_currentIndex == 1)
            IconButton(
              icon: Badge(
                label: Text(_cartItems.length.toString()),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () {},
            ),
        ],
      ),
      body: _currentIndex == 0 
          ? _buildProductsPage() 
          : CartPage(
              cartItems: _cartItems,
              onRemove: _removeFromCart,
              onCheckout: () => _showCheckoutDialog(context),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildProductsPage() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) => ProductCard(
        product: _products[index],
        onAddToCart: () => _addToCart(_products[index]),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    if (_cartItems.isEmpty) return;

    final total = _cartItems.fold(0.0, (sum, item) => sum + item.price);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PaymentSection(
          totalAmount: total,
          onPaymentComplete: (paymentMethod) {
            Navigator.pop(context);
            setState(() => _cartItems.clear());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Compra de R\$${total.toStringAsFixed(2)} via $paymentMethod realizada!'),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }
}