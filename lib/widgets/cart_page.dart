import 'package:flutter/material.dart';
import 'package:myapp/models/product.dart'; // Use seu nome de pacote

class CartPage extends StatelessWidget {
  final List<Product> cartItems;
  final Function(Product) onRemove;
  final VoidCallback onCheckout;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final total = cartItems.fold(0.0, (sum, item) => sum + item.price);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems[index];
      
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Total: R\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Finalizar Compra'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}