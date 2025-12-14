import 'package:flutter/material.dart';
import 'package:tewo_p/app_desktop/ops/product_batch_creator.dart';

class ItemsToolsPage extends StatelessWidget {
  final Map<String, dynamic>
  currentUser; // Use dynamic to avoid AttributeValue import if not needed directly
  final String usersTableName;
  final String businessPrefix;

  const ItemsToolsPage({
    super.key,
    required this.currentUser,
    required this.usersTableName,
    required this.businessPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items Tools'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 32,
          runSpacing: 32,
          children: [
            _buildToolButton(
              context,
              icon: Icons.add_box,
              label: 'Create Product',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductBatchCreatorPage(businessPrefix: businessPrefix),
                  ),
                );
              },
            ),
            _buildToolButton(
              context,
              icon: Icons.qr_code,
              label: 'ID Barcode Generator',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coming Soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
