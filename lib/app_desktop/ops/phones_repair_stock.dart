import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/app_desktop/ops/stock_management_page.dart';

class PhonesRepairStock extends StatefulWidget {
  final String businessPrefix;
  final bool canEdit;
  final bool canAdd;
  final bool canDelete;
  final String userAlias;

  const PhonesRepairStock({
    super.key,
    required this.businessPrefix,
    required this.canEdit,
    required this.canAdd,
    required this.canDelete,
    required this.userAlias,
  });

  @override
  State<PhonesRepairStock> createState() => _PhonesRepairStockState();
}

class _PhonesRepairStockState extends State<PhonesRepairStock>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, AttributeValue>> _products = [];
  List<Map<String, AttributeValue>> _filteredProducts = [];
  Map<String, AttributeValue>? _selectedProduct;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((item) {
        final matchesQuery = item.values.any(
          (val) => val.s?.toLowerCase().contains(query) ?? false,
        );
        return matchesQuery;
      }).toList();
    });
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tableName = '${widget.businessPrefix}_products';
      final scanOutput = await AwsService().client.scan(
        tableName: tableName,
        filterExpression: 'product_condition = :c AND product_status = :s',
        expressionAttributeValues: {
          ':c': AttributeValue(s: 'NEW'),
          ':s': AttributeValue(s: 'AVAILABLE'),
        },
      );
      setState(() {
        _products = scanOutput.items ?? [];
        _filteredProducts = _products;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading stock: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Main Products", icon: Icon(Icons.shopping_bag)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildMainProductsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildMainProductsTab() {
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Products',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (widget.canAdd)
                ElevatedButton.icon(
                  onPressed: _selectedProduct != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockManagementPage(
                                product: _selectedProduct!,
                                businessPrefix: widget.businessPrefix,
                                userAlias: widget.userAlias,
                              ),
                            ),
                          ).then((result) {
                            if (result == true) {
                              _fetchProducts();
                            }
                          });
                        }
                      : null,
                  icon: const Icon(
                    Icons.settings,
                  ), // Changed icon to settings/manage
                  label: const Text("Manage Stock"),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn:
                      false, // Hide checkbox, rely on row selection
                  columnSpacing: 32.0, // Increased from 16.0 for 'medium' size
                  horizontalMargin: 24.0, // Standard margin
                  headingRowHeight: 56.0, // Standard height
                  dataRowMinHeight: 48.0, // Standard height
                  dataRowMaxHeight: 64.0, // Accommodate content
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Tipo Producto')),
                    DataColumn(label: Text('Disp. Compatibles')),
                    DataColumn(label: Text('IDs Compatibles')),
                    DataColumn(label: Text('Precio Venta')),
                    DataColumn(label: Text('% IVA')),
                    DataColumn(label: Text('Precio Trabajo')),
                    DataColumn(label: Text('Precio Compra')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Estado')),
                  ],
                  rows: _filteredProducts.map((item) {
                    final price =
                        item['product_sell_price']?.n ??
                        item['product_sell_price']?.s ??
                        '0';
                    final tax =
                        item['product_sell_tax']?.n ??
                        item['product_sell_tax']?.s ??
                        '0';
                    final workPrice =
                        item['product_work_price']?.n ??
                        item['product_work_price']?.s ??
                        '0';
                    final boughtPrice =
                        item['product_bought_price']?.n ??
                        item['product_bought_price']?.s ??
                        '0';

                    return DataRow(
                      selected: _selectedProduct == item,
                      onSelectChanged: (selected) {
                        setState(() {
                          _selectedProduct = selected == true ? item : null;
                        });
                      },
                      cells: [
                        DataCell(Text(item['product_id']?.s ?? '')),
                        DataCell(Text(item['product_kind']?.s ?? '')),
                        DataCell(
                          Text(item['product_compatible_devices']?.s ?? ''),
                        ),
                        DataCell(Text(item['product_compatible_ids']?.s ?? '')),
                        DataCell(Text("\$ $price")),
                        DataCell(Text("$tax %")),
                        DataCell(Text("\$ $workPrice")),
                        DataCell(Text("\$ $boughtPrice")),
                        DataCell(
                          Text(
                            item['product_stock']?.n ??
                                item['product_stock']?.s ??
                                '0',
                          ),
                        ),
                        DataCell(Text(item['product_status']?.s ?? '')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
