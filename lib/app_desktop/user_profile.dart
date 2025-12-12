import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/l10n/manual_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, AttributeValue> currentUser;

  const UserProfileScreen({super.key, required this.currentUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _aliasController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _curpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isChangingPassword = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _aliasController.text = widget.currentUser['user_alias']?.s ?? '';
    _nameController.text = widget.currentUser['user_name']?.s ?? '';
    _emailController.text = widget.currentUser['user_mail']?.s ?? '';
    _phoneController.text = widget.currentUser['user_phone']?.s ?? '';
    _curpController.text = widget.currentUser['user_curp']?.s ?? '';
    // Password controller starts empty for the "Change Password" feature
    _passwordController.text = '';
  }

  Future<void> _updateProfile() async {
    if (_aliasController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isChangingPassword && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedUser = Map<String, AttributeValue>.from(widget.currentUser);
      updatedUser['user_alias'] = AttributeValue(s: _aliasController.text);
      updatedUser['user_name'] = AttributeValue(s: _nameController.text);
      updatedUser['user_mail'] = AttributeValue(s: _emailController.text);
      updatedUser['user_phone'] = AttributeValue(s: _phoneController.text);
      updatedUser['user_curp'] = AttributeValue(s: _curpController.text);

      if (_isChangingPassword && _passwordController.text.isNotEmpty) {
        updatedUser['user_password'] = AttributeValue(
          s: _passwordController.text,
        );
      } else {
        // Keep existing password
        updatedUser['user_password'] = widget.currentUser['user_password']!;
      }

      await AwsService().client.putItem(
        tableName: 'cano_users',
        item: updatedUser,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.save,
            ), // Or a specific translation like 'Profile Updated'
            backgroundColor: Colors.green,
          ),
        );
        // Optionally update the local state in parent or just pop
        Navigator.pop(context); // Go back after value is saved
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.username), // Using 'Username' or 'Profile'
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _aliasController,
              decoration: InputDecoration(labelText: localizations.alias),
              readOnly:
                  true, // Alias usually shouldn't change as it might be a key or identifier
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: localizations.name),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: localizations.email),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: localizations.phone),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _curpController,
              decoration: InputDecoration(labelText: localizations.curp),
            ),
            const SizedBox(height: 16),
            if (!_isChangingPassword)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isChangingPassword = true;
                  });
                },
                child: Text(localizations.changePassword),
              ),
            if (_isChangingPassword)
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: localizations.newPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showPassword,
              ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text(localizations.save),
                  ),
          ],
        ),
      ),
    );
  }
}
