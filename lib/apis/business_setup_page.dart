import 'package:flutter/material.dart';
import 'package:tewo_p/services/db_instruction_service.dart';
import 'package:tewo_p/app/loading_splash.dart';
import 'package:tewo_p/apis/aws_service.dart';

class BusinessSetupPage extends StatefulWidget {
  final Map<String, dynamic> packInstructions;
  final String
  packPath; // Path where the pack was unzipped to read extra config if needed

  const BusinessSetupPage({
    super.key,
    required this.packInstructions,
    required this.packPath,
  });

  @override
  State<BusinessSetupPage> createState() => _BusinessSetupPageState();
}

class _BusinessSetupPageState extends State<BusinessSetupPage> {
  final _formKey = GlobalKey<FormState>();

  // Business Controllers
  final _businessNameController = TextEditingController();
  final _prefixController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessLocationController = TextEditingController();
  final _businessPasswordController =
      TextEditingController(); // For business entity itself? Or owner?
  // Instructions said "bussiness_password" in business_data table.

  // Owner/User Controllers
  final _ownerNameController = TextEditingController();
  final _ownerAliasController = TextEditingController();
  final _ownerPasswordController = TextEditingController(); // For user login

  String _businessType = 'Retail'; // Default or dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Business')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Business Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: 'Business Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prefixController,
                decoration: const InputDecoration(
                  labelText: 'Prefix (e.g., VHR)',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessEmailController,
                decoration: const InputDecoration(labelText: 'Business Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessPhoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessLocationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Business Secret/Password',
                ),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 32),
              Text(
                'Owner Account',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerAliasController,
                decoration: const InputDecoration(
                  labelText: 'Owner Alias/Username',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Owner Login Password',
                ),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _showSummary,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text('Review & Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSummary() {
    if (!_formKey.currentState!.validate()) return;

    final businessData = {
      'bussiness_name': _businessNameController.text.trim(),
      'bussiness_prefix': _prefixController.text.trim(),
      'bussiness_email': _businessEmailController.text.trim(),
      'bussiness_phone': _businessPhoneController.text.trim(),
      'bussiness_location': _businessLocationController.text.trim(),
      'bussiness_type': _businessType,
      'bussiness_password': _businessPasswordController.text.trim(),
      'bussiness_owner': _ownerNameController.text.trim(),
    };

    final ownerData = {
      'user_name': _ownerNameController.text.trim(),
      'user_alias': _ownerAliasController.text.trim(),
      'user_email': _businessEmailController.text
          .trim(), // reusing business email or add separate field
      'user_phone': _businessPhoneController.text.trim(),
      'user_password': _ownerPasswordController.text.trim(),
      'user_role': 'Admin',
      'user_creation_date': DateTime.now().toIso8601String(),
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Business: ${businessData['bussiness_name']}'),
              Text('Prefix: ${businessData['bussiness_prefix']}'),
              const Divider(),
              Text('Owner: ${ownerData['user_name']}'),
              Text('Alias: ${ownerData['user_alias']}'),
              Text('Role: Admin'),
              const SizedBox(height: 20),
              const Text('Create tables and user?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _createTables(businessData, ownerData);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTables(
    Map<String, dynamic> businessData,
    Map<String, dynamic> ownerData,
  ) async {
    // We can't show "Creating Database..." splash immediately if we might need user input for PKs.
    // However, the Service only calls onPkRequest if needed.
    // If we are showing a modal barrier (LoadingSplash), we can't easily show a dialog on top without complex context handling or hiding splash first.
    // A better UX: Start splash. If PK needed, hide splash, show dialog, resume splash (handled by next call continuation or re-show).

    // BUT, the service loop runs in one go.
    // If we hide splash inside the callback, we need to show it again after.

    // Let's rely on the callback logic:
    // 1. Hide Splash
    // 2. Show Selection Dialog
    // 3. Return result
    // 4. (Service continues)
    // 5. We might need to handle re-showing splash? Or just let it be.
    // Actually, if we hide it, the user sees the form again. That's fine.
    // We should probably show "Resume..." splash after dialog.

    LoadingSplash.show(context: context, message: "Creating Database...");

    try {
      // Initialize AWS Service for Local DB (Default for now)
      // We FORCE localhost:8000 to ensure we don't pick up stray 8080 configs.
      print("Initializing Default Local AWS Service...");
      AwsService().init(
        accessKey: 'fake',
        secretKey: 'fake',
        region: 'us-west-2',
        endpointUrl: 'http://localhost:8000',
      );

      await DbInstructionService().createTables(
        prefix: businessData['bussiness_prefix'],
        instructions: widget.packInstructions,
        businessData: businessData,
        ownerData: ownerData,
        onPkRequest: (tableName, attributes) async {
          // Hide the 'Creating Database' splash to allow interaction
          LoadingSplash.hide(context);

          // Ask user
          String? selectedPk = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text('Select Partition Key for $tableName'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: attributes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(attributes[index]),
                      onTap: () => Navigator.pop(ctx, attributes[index]),
                    );
                  },
                ),
              ),
            ),
          );

          // Re-show splash
          if (mounted) {
            LoadingSplash.show(
              context: context,
              message: "Creating Database...",
            );
          }

          return selectedPk;
        },
      );

      if (mounted) {
        LoadingSplash.hide(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Setup Complete!')));
        Navigator.pop(context); // Pop setup
        Navigator.pop(context); // Pop details page
      }
    } catch (e) {
      if (mounted) {
        LoadingSplash.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
