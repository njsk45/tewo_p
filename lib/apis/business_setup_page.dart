import 'package:flutter/material.dart';
import 'package:tewo_p/services/db_instruction_service.dart';
import 'package:tewo_p/app/loading_splash.dart';
import 'package:tewo_p/l10n/manual_localizations.dart';

class BusinessSetupPage extends StatefulWidget {
  final Map<String, dynamic> packInstructions;
  final String
  packPath; // Path where the pack was unzipped to read extra config if needed
  final Map<String, dynamic> manifest;

  const BusinessSetupPage({
    super.key,
    required this.packInstructions,
    required this.packPath,
    required this.manifest,
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
  final _businessTargetController = TextEditingController();
  final _businessPasswordController =
      TextEditingController(); // For business entity itself? Or owner?
  // Instructions said "bussiness_password" in business_data table.

  // Owner/User Controllers
  final _ownerNameController = TextEditingController();
  final _ownerAliasController = TextEditingController();
  final _ownerPasswordController = TextEditingController(); // For user login

  String _businessType = 'Retail'; // Default or dropdown

  bool _isBusinessPasswordVisible = false;
  bool _isOwnerPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _initBusinessTarget();
  }

  void _initBusinessTarget() {
    // Extract business_target from manifest if available
    // Structure: bussiness_data -> bussiness_target
    final bizData = widget.manifest['bussiness_data'] as Map<String, dynamic>?;
    if (bizData != null && bizData.containsKey('bussiness_target')) {
      _businessTargetController.text = bizData['bussiness_target'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                controller: _businessTargetController,
                decoration: const InputDecoration(
                  labelText: 'Business Target',
                  filled: true,
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),
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
                decoration: InputDecoration(
                  labelText: 'Business Secret/Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isBusinessPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isBusinessPasswordVisible =
                            !_isBusinessPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isBusinessPasswordVisible,
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
                decoration: InputDecoration(
                  labelText: 'Owner Login Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOwnerPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOwnerPasswordVisible = !_isOwnerPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isOwnerPasswordVisible,
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

  void _showSummary() async {
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
      'bussiness_target': _businessTargetController.text.trim(), // Added
    };

    final ownerData = {
      'user_name': _ownerNameController.text.trim(),
      'user_alias': _ownerAliasController.text.trim(),
      'user_email': _businessEmailController.text.trim(),
      'user_phone': _businessPhoneController.text.trim(),
      'user_password': _ownerPasswordController.text.trim(),
      'user_role': 'Admin',
      'user_creation_date': DateTime.now().toIso8601String(),
    };

    // Show loading while generating preview
    LoadingSplash.show(context: context, message: "Generating Preview...");

    try {
      final dbService = DbInstructionService();
      final previews = await dbService.generatePreview(
        prefix: businessData['bussiness_prefix'] as String,
        instructions: widget.packInstructions,
        businessData: businessData,
        ownerData: ownerData,
      );

      if (mounted) LoadingSplash.hide(context);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => _PreviewDialog(
          previews: previews,
          onConfirm: () {
            Navigator.pop(ctx);
            _showStorageSelection(businessData, ownerData);
          },
        ),
      );
    } catch (e) {
      if (mounted) LoadingSplash.hide(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preview Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStorageSelection(
    Map<String, dynamic> businessData,
    Map<String, dynamic> ownerData,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Storage Mode'),
        content: const Text(
          'Choose how you want to store your data. DynamoDB is for cloud production, while Local Drift is for offline/local development.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement DynamoDB logic (Empty/Placeholder for now)
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('DynamoDB Mode coming soon...')),
              );
            },
            child: const Text('DynamoDB Mode'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _createTables(businessData, ownerData);
            },
            child: const Text('Local Drift Mode'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTables(
    Map<String, dynamic> businessData,
    Map<String, dynamic> ownerData,
  ) async {
    // ... (logic remains same, explicit context usage works if inside State)

    LoadingSplash.show(context: context, message: "Creating Database...");

    try {
      final dbService = DbInstructionService();

      print("Initializing Database Adapter (Local - Drift)...");
      dbService.useAdapter('local');
      await dbService.connect();

      await dbService.createTables(
        prefix: businessData['bussiness_prefix'],
        instructions: widget.packInstructions,
        businessData: businessData,
        ownerData: ownerData,
        onPkRequest: (tableName, attributes) async {
          LoadingSplash.hide(context);

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
        Navigator.pop(context);
        Navigator.pop(context);
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

class _PreviewDialog extends StatefulWidget {
  final List<Map<String, dynamic>> previews;
  final VoidCallback onConfirm;

  const _PreviewDialog({
    Key? key,
    required this.previews,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<_PreviewDialog> createState() => _PreviewDialogState();
}

class _PreviewDialogState extends State<_PreviewDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: widget.previews.length,
      child: AlertDialog(
        title: Text(l10n.databasePreview),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: widget.previews
                    .map((p) => Tab(text: p['tableName']))
                    .toList(),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
              ),
              Expanded(
                child: TabBarView(
                  children: widget.previews
                      .map((p) => _TableTab(preview: p))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: widget.onConfirm,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _TableTab extends StatefulWidget {
  final Map<String, dynamic> preview;
  const _TableTab({Key? key, required this.preview}) : super(key: key);

  @override
  State<_TableTab> createState() => _TableTabState();
}

class _TableTabState extends State<_TableTab> {
  final _hScrollController = ScrollController();
  final _vScrollController = ScrollController();

  @override
  void dispose() {
    _hScrollController.dispose();
    _vScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = (widget.preview['columns'] as List).cast<String>();
    final data = (widget.preview['data'] as List).cast<Map<String, dynamic>>();

    return Scrollbar(
      controller: _vScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _vScrollController,
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          controller: _hScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _hScrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns
                  .map((col) => DataColumn(label: Text(col)))
                  .toList(),
              rows: data.map((row) {
                return DataRow(
                  cells: columns.map((col) {
                    final isPassword = col.toLowerCase().contains('password');
                    final cellValue = row[col]?.toString() ?? '';
                    return DataCell(Text(isPassword ? '******' : cellValue));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
