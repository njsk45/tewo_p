//THIS PAGE IS TO CREATE PRODUCTS AND IT TO THE DB
//FOR NOW IS ONLY WORKIN FOR phones_repair PREFIX
//NOTE: YOU MUST KNOW HOW TO MANAGE bussines_prefix and bussines_target
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:tewo_p/apis/aws_service.dart';

class ProductBatchCreatorPage extends StatefulWidget {
  final String businessPrefix;

  const ProductBatchCreatorPage({super.key, required this.businessPrefix});

  @override
  State<ProductBatchCreatorPage> createState() =>
      _ProductBatchCreatorPageState();
}

class _ProductBatchCreatorPageState extends State<ProductBatchCreatorPage> {
  // State
  final List<Map<String, AttributeValue>> _localProducts = [];
  int _newProductsCounter = 0;
  int _lastId = 0;
  bool _isLoading = false;

  String get _tableName => '${widget.businessPrefix}_products';

  Future<void> _addProduct() async {
    // Open Dialog
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _ProductFormDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        int newId;
        // Logic: Connect to DB only if counter < 1
        if (_newProductsCounter < 1) {
          newId = await _fetchNextIdFromDb();
        } else {
          newId = _lastId + 1;
        }

        // Create Item
        final newItem = {
          'product_id': AttributeValue(s: newId.toString()),
          'product_kind': AttributeValue(s: result['kind'] ?? ''),
          'product_compatible_devices': AttributeValue(
            s: result['devices'] ?? '',
          ),
          'product_compatible_ids': AttributeValue(s: result['ids'] ?? ''),
          'product_sell_price': AttributeValue(n: result['sell_price'] ?? '0'),
          'product_sell_tax': AttributeValue(n: result['tax'] ?? '0'),
          'product_work_price': AttributeValue(n: result['work_price'] ?? '0'),
          'product_bought_price': AttributeValue(
            n: result['bought_price'] ?? '0',
          ),
          'product_stock': AttributeValue(n: result['stock'] ?? '0'),
          'product_status': AttributeValue(s: result['status'] ?? 'AVAILABLE'),
          'product_condition': AttributeValue(s: result['condition'] ?? 'NEW'),
        };

        setState(() {
          _localProducts.add(newItem);
          _newProductsCounter++;
          _lastId = newId;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating ID: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<int> _fetchNextIdFromDb() async {
    // Check if table exists? Assuming yes.
    try {
      final output = await AwsService().client.scan(
        tableName: _tableName,
        projectionExpression: 'product_id',
      );

      int maxId = 0;
      if (output.items != null) {
        for (var item in output.items!) {
          final idStr = item['product_id']?.s ?? item['product_id']?.n;
          if (idStr != null) {
            final id = int.tryParse(idStr);
            if (id != null && id > maxId) {
              maxId = id;
            }
          }
        }
      }
      return maxId + 1;
    } catch (e) {
      // If table doesn't exist or scan fails, maybe start at 1?
      // Or rethrow.
      print('Error fetching IDs: $e');
      throw e;
    }
  }

  Future<void> _uploadBatch() async {
    if (_localProducts.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      for (var item in _localProducts) {
        await AwsService().client.putItem(tableName: _tableName, item: item);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading batch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteLocalProduct(Map<String, AttributeValue> item) {
    setState(() {
      _localProducts.remove(item);
      // Note: deleting from local list doesn't reset counters or IDs
      // This is fine, we just skip that ID in the batch.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Batch Creator')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Kind')),
                          DataColumn(label: Text('Compatible Devices')),
                          DataColumn(label: Text('Condition')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Stock')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: _localProducts.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item['product_id']?.s ?? '')),
                              DataCell(Text(item['product_kind']?.s ?? '')),
                              DataCell(
                                Text(
                                  item['product_compatible_devices']?.s ?? '',
                                ),
                              ),
                              DataCell(
                                Text(item['product_condition']?.s ?? ''),
                              ),
                              DataCell(Text(item['product_status']?.s ?? '')),
                              DataCell(
                                Text(item['product_sell_price']?.n ?? ''),
                              ),
                              DataCell(Text(item['product_stock']?.n ?? '')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteLocalProduct(item),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                        onPressed: _addProduct,
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Batch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _localProducts.isNotEmpty
                            ? _uploadBatch
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog();

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kindController = TextEditingController();
  final _devicesController = TextEditingController();
  final _idsController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _taxController = TextEditingController(text: '16'); // Default tax
  final _workPriceController = TextEditingController();
  final _boughtPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');

  String _selectedCondition = 'NEW';
  String _selectedStatus = 'Automatic';

  String? _validateNumber(String? value, {bool isInt = false}) {
    if (value == null || value.isEmpty) return 'Required';
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Invalid number';
    if (numValue < 0) return 'Cannot be negative';
    if (isInt && int.tryParse(value) == null) return 'Must be an integer';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Product Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _kindController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Product Kind (e.g. SCREEN)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: ['NEW', 'RENEWED']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCondition = v!),
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Automatic', 'PENDING']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),
              TextFormField(
                controller: _devicesController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Compatible Devices',
                ),
              ),
              TextFormField(
                controller: _idsController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Compatible IDs'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Sell Price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNumber(v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _taxController,
                      decoration: const InputDecoration(labelText: 'Tax %'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNumber(v),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _workPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Work Price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNumber(v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _boughtPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Bought Price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNumber(v),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (v) => _validateNumber(v, isInt: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Logic check on Done
              String finalStatus = _selectedStatus;
              if (finalStatus == 'Automatic') {
                final stock = int.tryParse(_stockController.text) ?? 0;
                finalStatus = stock == 0 ? 'NO STOCK' : 'AVAILABLE';
              }

              Navigator.pop(context, {
                'kind': _kindController.text.toUpperCase(),
                'devices': _devicesController.text.toUpperCase(),
                'ids': _idsController.text.toUpperCase(),
                'sell_price': _sellPriceController.text,
                'tax': _taxController.text,
                'work_price': _workPriceController.text,
                'bought_price': _boughtPriceController.text,
                'stock': _stockController.text,
                'status': finalStatus,
                'condition': _selectedCondition,
              });
            }
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
