import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {
  runApp(const MyApp());
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Armazém da Dona Lurdes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Armazém da Dona Lurdes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    Product(
      id: '4',
      name: 'Batata',
      description: 'Batata inglesa vendida em pacotes de 1kg',
      price: 2.99,
    ),
    Product(
      id: '5',
      name: 'Batata doce',
      description: 'Batata doce vendida em pacotes de 1kg',
      price: 3.50,
    ),
    Product(
      id: '6',
      name: 'Morango',
      description: 'Bandeja com 400g',
      price: 5.99,
    ),
    Product(
      id: '7',
      name: 'Beterraba',
      description: 'Beterraba vendida em pacotes de 1kg',
      price: 2.75,
    ),
    Product(
      id: '8',
      name: 'Abobrinha',
      description: 'Abobrinha vendida em pacotes de 1kg',
      price: 1.99,
    ),
    Product(
      id: '9',
      name: 'Tomate',
      description: 'Tomate cereja vendida em bandeja com 400g',
      price: 6.00,
    ),
     Product(
      id: '10',
      name: 'Lichia',
      description: 'Pacotes vendidos com 1kg',
      price: 39.90,
    ),
     Product(
      id: '11',
      name: 'Framboesa',
      description: 'Bandeja com 400g',
      price: 21.75,
    ),
  ];
  final List<Product> _cartItems = [];

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} adicionado ao carrinho')),
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartItems.remove(product);
    });
  }

  void _completePurchase() {
    setState(() {
      _cartItems.clear();
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compra finalizada'),
        content: const Text('Obrigado por sua compra!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione itens ao carrinho primeiro')),
      );
      return;
    }

    final total = _cartItems.fold(0.0, (sum, item) => sum + item.price);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Pagamento')),
          body: PaymentSection(
            totalAmount: total,
            onPaymentComplete: _completePurchase,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _currentIndex == 0 ? _buildProductsPage() : _buildCheckoutPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildProductsPage() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(product.description),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(product),
                      child: const Text('Adicionar ao carrinho'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutPage() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final product = _cartItems[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('R\$${product.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeFromCart(product),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Total: R\$${_cartItems.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cartItems.isEmpty ? null : _checkout,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Ir para Pagamento'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaymentSection extends StatefulWidget {
  final double totalAmount;
  final Function onPaymentComplete;
  
  const PaymentSection({
    super.key,
    required this.totalAmount,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  String _selectedPaymentMethod = 'PIX';
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  bool _isProcessing = false;

  final _cardNumberFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _cardExpiryFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  bool _isValidCardNumber(String digits) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return (sum % 10 == 0);
  }

  void _processPayment() {
    if (_selectedPaymentMethod == 'PIX') {
      _showPixPaymentDialog();
    } else if (_selectedPaymentMethod == 'CREDIT_CARD') {
      _processCreditCardPayment();
    } else if (_selectedPaymentMethod == 'BOLETO') {
      _showBoletoPaymentDialog();
    }
  }

  void _processCreditCardPayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isProcessing = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pagamento Aprovado'),
          content: const Text('Seu pagamento foi processado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onPaymentComplete();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _showPixPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pagamento via PIX'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chave PIX: loja@exemplo.com.br'),
            const SizedBox(height: 16),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.qr_code, size: 100, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  const Text('Scanee o QR Code no seu app bancário'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Valor: R\$${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pagamento instantâneo com 5% de desconto',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPaymentComplete();
            },
            child: const Text('Já paguei'),
          ),
        ],
      ),
    );
  }

  void _showBoletoPaymentDialog() {
    final dueDate = DateTime.now().add(const Duration(days: 3));
    final formattedDate = DateFormat('dd/MM/yyyy').format(dueDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pagamento via Boleto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Boleto bancário gerado com sucesso!'),
            const SizedBox(height: 16),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.description, size: 50, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  const Text('Número do boleto: 34191.79001 01043.510047 91020.150008 5 87650000019999'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Valor: R\$${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vencimento: $formattedDate',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPaymentComplete();
            },
            child: const Text('Copiar Código'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPaymentComplete();
            },
            child: const Text('Imprimir Boleto'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Número do Cartão',
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _cardNumberFormatter,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o número do cartão';
              }
              
              final digits = value.replaceAll(' ', '');
              if (digits.length != 16) {
                return 'Número do cartão inválido';
              }
              
              if (!_isValidCardNumber(digits)) {
                return 'Número do cartão inválido';
              }
              
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNameController,
            decoration: const InputDecoration(
              labelText: 'Nome no Cartão',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome no cartão';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cardExpiryController,
                  decoration: const InputDecoration(
                    labelText: 'Validade (MM/AA)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _cardExpiryFormatter,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira a validade';
                    }
                    if (value.length != 5) {
                      return 'Formato inválido (MM/AA)';
                    }
                    
                    final parts = value.split('/');
                    if (parts.length != 2) return 'Formato inválido';
                    
                    final month = int.tryParse(parts[0]);
                    final year = int.tryParse(parts[1]);
                    
                    if (month == null || year == null) return 'Data inválida';
                    if (month < 1 || month > 12) return 'Mês inválido';
                    
                    final now = DateTime.now();
                    final currentYear = now.year % 100;
                    final currentMonth = now.month;
                    
                    if (year < currentYear || (year == currentYear && month < currentMonth)) {
                      return 'Cartão expirado';
                    }
                    
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cardCvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o CVV';
                    }
                    if (value.length != 3) {
                      return 'CVV inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.credit_card, size: 40),
              const SizedBox(width: 10),
              Icon(Icons.credit_card, size: 30, color: Colors.blue),
              const SizedBox(width: 10),
              Icon(Icons.credit_card, size: 30, color: Colors.orange),
              const SizedBox(width: 10),
              Icon(Icons.credit_card, size: 30, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String description,
    required IconData icon,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total a pagar: R\$${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Forma de Pagamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildPaymentMethodTile(
            title: 'PIX',
            description: 'Pagamento instantâneo com 5% de desconto',
            icon: Icons.pix,
            value: 'PIX',
          ),
          
          _buildPaymentMethodTile(
            title: 'Cartão de Crédito',
            description: 'Em até 12x no cartão',
            icon: Icons.credit_card,
            value: 'CREDIT_CARD',
          ),
          
          if (_selectedPaymentMethod == 'CREDIT_CARD') ...[
            const SizedBox(height: 16),
            _buildCreditCardForm(),
          ],
          
          _buildPaymentMethodTile(
            title: 'Boleto Bancário',
            description: 'Pagamento em até 3 dias úteis',
            icon: Icons.receipt,
            value: 'BOLETO',
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Confirmar Pagamento',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}