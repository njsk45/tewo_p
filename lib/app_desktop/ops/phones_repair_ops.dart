//TO DETERMINATE WHAT WILL SEE THE phones_repair PREFIX at Operations Tab
//NOTE: YOU MUST KNOW HOW TO MANAGE bussines_prefix and bussines_target
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:tewo_p/apis/aws_service.dart';

class PhonesRepairOperations extends StatefulWidget {
  final String businessPrefix;

  const PhonesRepairOperations({super.key, required this.businessPrefix});

  @override
  State<PhonesRepairOperations> createState() => _PhonesRepairOperationsState();
}

class _PhonesRepairOperationsState extends State<PhonesRepairOperations> {
  bool _isLoading = true;
  List<Map<String, AttributeValue>> _products = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tableName = '${widget.businessPrefix}_products';
      final scanOutput = await AwsService().client.scan(tableName: tableName);
      setState(() {
        _products = scanOutput.items ?? [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading products: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    /*
    product_id = "ID",
    product_kind = "Tipo de Producto",
    product_compatible_devices = "Dispositivos Compatibles",
    product_compatible_ids = "IDs Compatibles",
    product_sell_price = "Precio Individual",
    product_sell_tax = "% de IVA",
    product_work_price = "Precio de Trabajo",
    product_bought_price = "Precio de Compra".
    */

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Phones Repair Operations - Products",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Tipo de Producto')),
                      DataColumn(label: Text('Dispositivos Compatibles')),
                      DataColumn(label: Text('IDs Compatibles')),
                      DataColumn(label: Text('Precio Individual')),
                      DataColumn(label: Text('% de IVA')),
                      DataColumn(label: Text('Precio de Trabajo')),
                      DataColumn(label: Text('Precio de Compra')),
                    ],
                    rows: _products.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item['product_id']?.s ?? '')),
                          DataCell(Text(item['product_kind']?.s ?? '')),
                          DataCell(
                            Text(item['product_compatible_devices']?.s ?? ''),
                          ),
                          DataCell(
                            Text(item['product_compatible_ids']?.s ?? ''),
                          ),
                          DataCell(
                            Text(
                              item['product_sell_price']?.n ??
                                  item['product_sell_price']?.s ??
                                  '',
                            ),
                          ),
                          DataCell(
                            Text(
                              item['product_sell_tax']?.n ??
                                  item['product_sell_tax']?.s ??
                                  '',
                            ),
                          ),
                          DataCell(
                            Text(
                              item['product_work_price']?.n ??
                                  item['product_work_price']?.s ??
                                  '',
                            ),
                          ),
                          DataCell(
                            Text(
                              item['product_bought_price']?.n ??
                                  item['product_bought_price']?.s ??
                                  '',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
