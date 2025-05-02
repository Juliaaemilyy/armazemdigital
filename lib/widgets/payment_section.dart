import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PaymentSection extends StatefulWidget {
  final double totalAmount;
  final void Function(String) onPaymentComplete;
  
  
  const PaymentSection({
    Key? key,
    required this.totalAmount,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

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

  Future<void> _processPayment(String method) async {
    if (method == 'CREDIT_CARD' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    
    if (method == 'BOLETO') {
      _showBoletoConfirmation();
    } else {
      widget.onPaymentComplete(method);
    }
  }

  void _handlePayment() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um método de pagamento')),
      );
      return;
    }

    _processPayment(_selectedPaymentMethod!);
  }

  Widget _buildCreditCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Número do Cartão',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _cardNumberFormatter,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo obrigatório';
              if (value.replaceAll(' ', '').length != 16) return 'Número inválido';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNameController,
            decoration: const InputDecoration(
              labelText: 'Nome no Cartão',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo obrigatório';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cardExpiryController,
                  decoration: const InputDecoration(
                    labelText: 'Validade (MM/AA)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _cardExpiryFormatter,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    if (value.length != 5) return 'Formato inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cardCvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    if (value.length != 3) return 'CVV inválido';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String description,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedPaymentMethod = value),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() => _selectedPaymentMethod = value);
                },
              ),
              const SizedBox(width: 8),
              Icon(icon, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoletoDetails() {
    final dueDate = DateTime.now().add(const Duration(days: 3));
    final formattedDate = DateFormat('dd/MM/yyyy').format(dueDate);
    final formattedBarcode = '34191.79001 01043.510047 91020.150008 5 87650000019999';

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Boleto Bancário',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBoletoInfoItem(Icons.calendar_today, 'Vencimento:', formattedDate),
            _buildBoletoInfoItem(Icons.attach_money, 'Valor:', 
              'R\$${widget.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'Código de Barras:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              formattedBarcode,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Código'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: formattedBarcode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Salvar PDF'),
                    onPressed: () {
                      _showBoletoConfirmation();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoletoInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showBoletoConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Boleto Gerado'),
        content: const Text('O boleto foi gerado com sucesso. Você pode pagar em qualquer agência bancária ou internet banking.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPaymentComplete('BOLETO');
            },
            child: const Text('Já efetuei o pagamento'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Total: R\$${widget.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecione o método de pagamento:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    icon: Icons.pix,
                    title: 'PIX',
                    description: 'Pagamento instantâneo',
                    value: 'PIX',
                  ),
                  _buildPaymentOption(
                    icon: Icons.credit_card,
                    title: 'Cartão de Crédito',
                    description: 'Parcelamento em até 12x',
                    value: 'CREDIT_CARD',
                  ),
                  if (_selectedPaymentMethod == 'CREDIT_CARD') ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildCreditCardForm(),
                      ),
                    ),
                  ],
                  _buildPaymentOption(
                    icon: Icons.receipt,
                    title: 'Boleto Bancário',
                    description: 'Pagamento em até 3 dias úteis',
                    value: 'BOLETO',
                  ),
                  if (_selectedPaymentMethod == 'BOLETO') 
                    _buildBoletoDetails(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              onPressed: _isProcessing ? null : _handlePayment,
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Pagar R\$${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                      
                    ),
            ),
          ),
        ],
      ),
    );
  }
}