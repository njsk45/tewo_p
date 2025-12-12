import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/l10n/manual_localizations.dart';

class UsersManagementScreen extends StatefulWidget {
  final bool canEdit;
  final bool canAdd;
  final Map<String, AttributeValue> currentUser;

  const UsersManagementScreen({
    super.key,
    required this.canEdit,
    required this.canAdd,
    required this.currentUser,
  });

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<Map<String, AttributeValue>> _allUsers = [];
  List<Map<String, AttributeValue>> _filteredUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _itemsPerPage = 10;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      // Scan all users. For a large database, this should be paginated server-side,
      // but for this requirement and likely dataset size, scanning all is acceptable
      // to support flexible client-side search.
      final output = await AwsService().client.scan(tableName: 'cano_users');
      if (output.items != null) {
        setState(() {
          _allUsers = output.items!;
          _filterUsers();
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorFetchingUsers),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterUsers() {
    final query = _searchQuery.toLowerCase();
    setState(() {
      final currentUserId =
          widget.currentUser['user_id']?.n ?? widget.currentUser['user_id']?.s;

      _filteredUsers = _allUsers.where((user) {
        // Filter out current user
        final userId = user['user_id']?.n ?? user['user_id']?.s;
        if (userId == currentUserId) return false;

        final alias = user['user_alias']?.s?.toLowerCase() ?? '';
        final name = user['user_name']?.s?.toLowerCase() ?? '';
        final role = user['user_role']?.s?.toLowerCase() ?? '';
        final email = user['user_mail']?.s?.toLowerCase() ?? '';
        final curp = user['user_curp']?.s?.toLowerCase() ?? '';

        return alias.contains(query) ||
            name.contains(query) ||
            role.contains(query) ||
            email.contains(query) ||
            curp.contains(query);
      }).toList();
      _currentPage = 0; // Reset to first page on search
    });
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _filterUsers();
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(AppLocalizations.of(context)!.deleteUserConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AwsService().client.deleteItem(
          tableName: 'cano_users',
          key: {
            'user_id': AttributeValue(n: userId),
          }, // Using user_id (Number) as PK
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.userDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchUsers(); // Refresh list
      } catch (e) {
        print('Error deleting user: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // Identify primary key for editing.
  // Assuming user_alias is PK.
  // Warning: Editing PK usually implies deleting and creating new,
  // but let's assume we edit other fields.
  Future<void> _editUser(Map<String, AttributeValue> user) async {
    // Determine the schema for editing.
    // For now, simple text fields for name, role, mail, curp.
    // Alias is PK, so it should be read-only or handle PK change carefully.
    // Password should probably be changeable? User said "do not show passwords table",
    // doesn't explicitly forbid editing them, but let's stick to showing details for now.

    final localizations = AppLocalizations.of(context)!;

    final aliasController = TextEditingController(
      text: user['user_alias']?.s ?? '',
    );
    final nameController = TextEditingController(
      text: user['user_name']?.s ?? '',
    );

    final emailController = TextEditingController(
      text: user['user_mail']?.s ?? '',
    );
    final curpController = TextEditingController(
      text: user['user_curp']?.s ?? '',
    );
    final passwordController = TextEditingController(); // Start empty

    String? selectedRole = user['user_role']?.s?.toUpperCase();
    if (!['ADMIN', 'MODERATOR', 'EMPLOYEE'].contains(selectedRole)) {
      selectedRole = 'EMPLOYEE'; // Default fallback
    }

    // Simple Dialog for Editing
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(localizations.editUser),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: aliasController,
                    decoration: InputDecoration(labelText: localizations.alias),
                    readOnly: true, // Primary key usually rigid
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: localizations.name),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(labelText: localizations.role),
                    items: ['ADMIN', 'MODERATOR', 'EMPLOYEE']
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRole = value;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: localizations.email),
                  ),
                  TextField(
                    controller: curpController,
                    decoration: InputDecoration(labelText: localizations.curp),
                  ),
                  TextField(
                    controller: TextEditingController(
                      text: user['user_creation_date']?.s?.split('T')[0] ?? '',
                    ),
                    decoration: InputDecoration(
                      labelText: localizations.creationDate,
                    ),
                    readOnly: true,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: localizations.newPassword,
                      hintText: 'Leave empty to keep current',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final newPassword = passwordController.text;
                    // Preserve existing password if new one is empty
                    final passwordAttr = newPassword.isNotEmpty
                        ? AttributeValue(s: newPassword)
                        : user['user_password'];

                    // Create a mutable copy of the original user item to preserve all fields
                    final updatedItem = Map<String, AttributeValue>.from(user);

                    // Update modified fields
                    updatedItem['user_alias'] = AttributeValue(
                      s: aliasController.text,
                    );
                    updatedItem['user_name'] = AttributeValue(
                      s: nameController.text,
                    );
                    updatedItem['user_role'] = AttributeValue(
                      s: selectedRole ?? 'EMPLOYEE',
                    );
                    updatedItem['user_mail'] = AttributeValue(
                      s: emailController.text,
                    );
                    updatedItem['user_curp'] = AttributeValue(
                      s: curpController.text,
                    );

                    // Handle password
                    if (passwordAttr != null) {
                      updatedItem['user_password'] = passwordAttr;
                    }

                    await AwsService().client.putItem(
                      tableName: 'cano_users',
                      item: updatedItem,
                    );
                    if (context.mounted) Navigator.pop(context);
                    _fetchUsers();
                  } catch (e) {
                    print('Error updating user: $e');
                  }
                },
                child: Text(localizations.save),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createUser() async {
    final localizations = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final aliasController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final curpController = TextEditingController();
    final phoneController = TextEditingController();
    final currentUserRole = widget.currentUser['user_role']?.s?.toUpperCase();
    final List<String> roles = currentUserRole == 'ADMIN'
        ? ['ADMIN', 'MODERATOR', 'EMPLOYEE']
        : ['EMPLOYEE'];

    String? selectedRole = roles.first; // Default to first available

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) {
          return AlertDialog(
            title: Text(localizations.createUser),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: aliasController,
                    decoration: InputDecoration(labelText: localizations.alias),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: localizations.name),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedRole = value),
                    decoration: InputDecoration(labelText: localizations.role),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: localizations.password,
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: localizations.email),
                  ),
                  TextField(
                    controller: curpController,
                    decoration: InputDecoration(labelText: localizations.curp),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: localizations.phone),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (aliasController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(localizations.fillAllFields),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    // Calculate next user_id
                    int maxId = 0;
                    for (var user in _allUsers) {
                      // Check both 'n' and 's' just to be safe, prioritizing 'n'
                      final idStr = user['user_id']?.n ?? user['user_id']?.s;
                      if (idStr != null) {
                        final id = int.tryParse(idStr);
                        if (id != null && id > maxId) {
                          maxId = id;
                        }
                      }
                    }
                    final newUserId = (maxId + 1).toString();

                    await AwsService().client.putItem(
                      tableName: 'cano_users',
                      item: {
                        'user_alias': AttributeValue(s: aliasController.text),
                        'user_id': AttributeValue(
                          n: newUserId,
                        ), // Send as Number

                        'user_name': AttributeValue(s: nameController.text),
                        'user_role': AttributeValue(s: selectedRole),
                        'user_password': AttributeValue(
                          s: passwordController.text,
                        ),
                        'user_mail': AttributeValue(s: emailController.text),
                        'user_curp': AttributeValue(s: curpController.text),
                        'user_phone': AttributeValue(s: phoneController.text),
                        'user_creation_date': AttributeValue(
                          s: DateTime.now().toIso8601String(),
                        ),
                        'is_active': AttributeValue(s: 'INACTIVE'),
                      },
                    );
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(localizations.createUserSuccess),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    _fetchUsers();
                  } catch (e) {
                    print('Error creating user: $e');
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(localizations.save),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pagination logic
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < _filteredUsers.length)
        ? startIndex + _itemsPerPage
        : _filteredUsers.length;
    final displayedUsers = _filteredUsers.sublist(startIndex, endIndex);

    final totalPages = (_filteredUsers.length / _itemsPerPage).ceil();

    return Column(
      children: [
        // Header: Title and Search
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.usersList,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.canAdd) ...[
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _createUser,
                  tooltip: AppLocalizations.of(context)!.createUser,
                ),
              ],
              const SizedBox(width: 32),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchUser,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : displayedUsers.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noUsersFound))
              : SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(AppLocalizations.of(context)!.alias),
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context)!.name),
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context)!.role),
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context)!.email),
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context)!.curp),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context)!.creationDate,
                          ),
                        ),
                        if (widget.canEdit)
                          DataColumn(
                            label: Text(AppLocalizations.of(context)!.actions),
                          ),
                      ],
                      rows: displayedUsers.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user['user_alias']?.s ?? '')),
                            DataCell(Text(user['user_name']?.s ?? '')),
                            DataCell(Text(user['user_role']?.s ?? '')),
                            DataCell(Text(user['user_mail']?.s ?? '')),
                            DataCell(Text(user['user_curp']?.s ?? '')),
                            DataCell(
                              Text(
                                user['user_creation_date']?.s?.split('T')[0] ??
                                    '',
                              ),
                            ),
                            if (widget.canEdit)
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _editUser(user),
                                      tooltip: AppLocalizations.of(
                                        context,
                                      )!.edit,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        // Prioritize 'n', fallback to 's', handle null
                                        final userId =
                                            user['user_id']?.n ??
                                            user['user_id']?.s;
                                        if (userId != null) {
                                          _deleteUser(userId);
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Error: specific user_id missing',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      tooltip: AppLocalizations.of(
                                        context,
                                      )!.delete,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
        // Pagination Controls
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  child: Text(AppLocalizations.of(context)!.previous),
                ),
                const SizedBox(width: 16),
                Text('Page ${_currentPage + 1} of $totalPages'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                  child: Text(AppLocalizations.of(context)!.next),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
