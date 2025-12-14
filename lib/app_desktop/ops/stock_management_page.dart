//Manage Stock Settings
//TO ENTER HERE STOCK/INVENTORY TAB > MANAGE STOCK BUTTON
//NOTE: YOU MUST KNOW HOW TO MANAGE bussines_prefix and bussines_target
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/apis/email_templates.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class StockManagementPage extends StatefulWidget {
  final Map<String, AttributeValue> product;
  final String businessPrefix;
  final String userAlias;

  const StockManagementPage({
    super.key,
    required this.product,
    required this.businessPrefix,
    required this.userAlias,
  });

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  // Constants
  static const String reasonSelect = "Select an option";
  static const String reasonTransfer = "Transfer";
  static const String reasonCleaning = "Cleaning";
  static const String reasonOther = "Other Reason";

  // State
  int _currentStock = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Add Stock State
  final TextEditingController _addStockController = TextEditingController();

  // Decrease Stock State
  String _selectedReason = reasonSelect;
  final TextEditingController _decreaseReasonDetailController =
      TextEditingController();
  final TextEditingController _decreaseStockController =
      TextEditingController();

  // Verification State
  bool _isVerificationMode = false;
  String? _generatedCode;
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isDecretionMode = false; // After successful verification

  // Business Data for Email
  Map<String, dynamic> _businessData = {};

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _currentStock =
        int.tryParse(
          widget.product['product_stock']?.n ??
              widget.product['product_stock']?.s ??
              '0',
        ) ??
        0;
    _fetchBusinessData();
  }

  @override
  void dispose() {
    _addStockController.dispose();
    _decreaseReasonDetailController.dispose();
    _decreaseStockController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchBusinessData() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assets/json/dkskdp/oxfek.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final envelope = jsonDecode(content);
        final iv = encrypt.IV.fromBase64(envelope['iv']);
        final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
        final encrypter = encrypt.Encrypter(encrypt.AES(key));
        final decrypted = encrypter.decrypt(
          encrypt.Encrypted.fromBase64(envelope['content']),
          iv: iv,
        );
        final settings = jsonDecode(decrypted);
        final businessName = settings['bussiness_name'];

        if (businessName != null) {
          final scanOutput = await AwsService().client.scan(
            tableName: 'clients_setups',
            filterExpression: 'bussiness_name = :n',
            expressionAttributeValues: {':n': AttributeValue(s: businessName)},
          );
          if (scanOutput.items != null && scanOutput.items!.isNotEmpty) {
            final item = scanOutput.items!.first;
            _businessData = {'owner_email': item['owner_email']?.s ?? ''};
          }
        }
      }
    } catch (e) {
      print("Error fetching business data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Future<void> _addStock() async {
    final toAdd = int.tryParse(_addStockController.text);
    if (toAdd == null || toAdd < 0) return;

    setState(() => _isLoading = true);
    try {
      final newStock = _currentStock + toAdd;
      await _updateStockInDB(newStock);
      setState(() {
        _currentStock = newStock;
        _addStockController.clear();
      });
      _showSnack("Stock added successfully");
    } catch (e) {
      _showSnack("Error adding stock: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initiateDecreaseVerification() async {
    final toRemove = int.tryParse(_decreaseStockController.text);
    if (toRemove == null || toRemove <= 0) {
      _showSnack("Please enter a valid amount greater than 0.", isError: true);
      return;
    }
    if (toRemove > _currentStock) {
      _showSnack("Cannot remove more than current stock.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _sendVerificationEmail();
      setState(() {
        _isVerificationMode = true;
      });
    } catch (e) {
      _showSnack("Error sending verification email: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndProceed() async {
    if (_verificationCodeController.text == _generatedCode) {
      setState(() {
        _isVerificationMode = false;
        _isDecretionMode = true;
      });
    } else {
      _showSnack("Invalid Code", isError: true);
    }
  }

  Future<void> _decreaseStock() async {
    final toRemove = int.tryParse(_decreaseStockController.text);
    if (toRemove == null || toRemove < 0) return;

    if (toRemove > _currentStock) {
      _showSnack("Cannot remove more than current stock.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newStock = _currentStock - toRemove;
      await _updateStockInDB(newStock);
      setState(() {
        _currentStock = newStock;
        _decreaseStockController.clear();
        _isDecretionMode = false;
        _selectedReason = reasonSelect; // Reset reason
      });
      // Return true to indicate change happened, but we don't pop immediately unless desired.
      // The user might want to continue editing.
      // If we want to stay on page, just show snack.
      _showSnack("Stock decreased successfully");
    } catch (e) {
      _showSnack("Error decreasing stock: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStockInDB(int newStock) async {
    await AwsService().client.updateItem(
      tableName: '${widget.businessPrefix}_products',
      key: {'product_id': widget.product['product_id']!},
      attributeUpdates: {
        'product_stock': AttributeValueUpdate(
          action: AttributeAction.put,
          value: AttributeValue(n: newStock.toString()),
        ),
      },
    );
  }

  Future<void> _sendVerificationEmail() async {
    final rnd = Random();
    _generatedCode = (rnd.nextInt(900000) + 100000).toString();

    // Using same SMTP logic
    final tewoScan = await AwsService().client.scan(
      tableName: 'clients_setups',
      filterExpression: 'bussiness_name = :n',
      expressionAttributeValues: {':n': AttributeValue(s: 'TeWo')},
    );
    if (tewoScan.items == null || tewoScan.items!.isEmpty)
      throw Exception("System Error: SMTP Provider not found");

    final tewoItem = tewoScan.items!.first;
    final smtpUser = tewoItem['owner_email']?.s;
    final smtpPass = tewoItem['bussiness_key']?.s;

    if (smtpUser == null || smtpPass == null)
      throw Exception("System Error: Invalid SMTP config");

    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      username: smtpUser,
      password: smtpPass,
    );

    String reasonText = _selectedReason;
    if (_selectedReason == reasonTransfer || _selectedReason == reasonOther) {
      reasonText += ": ${_decreaseReasonDetailController.text}";
    }

    final toRemove = int.tryParse(_decreaseStockController.text) ?? 0;
    final newStock = _currentStock - toRemove;
    final productId = widget.product['product_id']?.s ?? 'Unknown';

    final message = Message()
      ..from = Address(smtpUser, 'TeWo Settings Security')
      ..recipients.add(_businessData['owner_email'])
      ..subject = EmailTemplates.stockDecretionSubject
      ..text = EmailTemplates.stockDecretionBody(
        userAlias: widget.userAlias,
        productId: productId,
        reasonText: reasonText,
        currentStock: _currentStock,
        stockToDecrease: toRemove,
        newStock: newStock,
        verificationCode: _generatedCode!,
      );

    await send(message, smtpServer);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Manage Stock > Product ID: ${widget.product['product_id']?.s ?? 'Unknown'}",
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Always return true to force refresh as we don't track perfectly if changes happened vs cancelled
              // Or better, track modification. For now, assuming refresh is cheap safe default or if _currentStock changed.
              // Let's just pop 'true' to be safe.
              Navigator.pop(context, true);
            },
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isVerificationMode) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Verify Stock Decretion",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text("Enter the code sent to the owner's email."),
          const SizedBox(height: 16),
          TextField(
            controller: _verificationCodeController,
            decoration: const InputDecoration(
              labelText: "Verification Code",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _isVerificationMode = false),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _verifyAndProceed,
                child: const Text("Verify"),
              ),
            ],
          ),
        ],
      );
    }

    if (_isDecretionMode) {
      final toRemove = _decreaseStockController.text;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Confirm Stock Removal",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            "Verified! You are about to remove $toRemove items from stock.",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _isDecretionMode = false),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _decreaseStock,
                child: const Text(
                  "Remove Stock",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    "Current Stock",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$_currentStock",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text("Add Stock", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addStockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount to Add",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add),
                  ),
                  onSubmitted: (_) => _addStock(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _addStock,
                icon: const Icon(Icons.save),
                label: const Text("Add"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 32),
          Text("Decrease Stock", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Reason",
              border: OutlineInputBorder(),
            ),
            value: _selectedReason,
            items: [
              reasonSelect,
              reasonTransfer,
              reasonCleaning,
              reasonOther,
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),
          const SizedBox(height: 16),
          if (_selectedReason == reasonTransfer)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _decreaseReasonDetailController,
                decoration: const InputDecoration(
                  labelText: "Transfer Destination",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
            ),
          if (_selectedReason == reasonOther)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _decreaseReasonDetailController,
                decoration: const InputDecoration(
                  labelText: "Specify Reason",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _decreaseStockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount to Remove",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.remove),
                  ),
                  onSubmitted: (_) => _selectedReason == reasonSelect
                      ? null
                      : _initiateDecreaseVerification(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _selectedReason == reasonSelect
                    ? null
                    : _initiateDecreaseVerification,
                icon: const Icon(Icons.delete_forever),
                label: const Text("Decrease"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
