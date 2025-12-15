import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tewo_p/l10n/manual_localizations.dart';

// -----------------------------------------------------------------------------
// PHASE 3B: BEHAVIOR MANAGER PAGE
// -----------------------------------------------------------------------------
class BehaviorManagerPage extends StatefulWidget {
  const BehaviorManagerPage({super.key});

  @override
  State<BehaviorManagerPage> createState() => _BehaviorManagerPageState();
}

class _BehaviorManagerPageState extends State<BehaviorManagerPage> {
  final String _testPath =
      r'c:\Users\Arzeuk\Documents\Code Projects\tewo_p\#dynamic_json_widgets_test';
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final dir = Directory(_testPath);
      if (await dir.exists()) {
        final List<FileSystemEntity> entities = await dir.list().toList();
        setState(() {
          _files = entities
              .where(
                (e) => e.path.endsWith('.json') || e.path.endsWith('.yaml'),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading packs: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.behaviorManager)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar: Search & Import
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: l10n.searchPack,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: Text(l10n.import),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      onPressed: () {
                        _loadFiles(); // Refresh
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Table Title
                Text(
                  "${l10n.availablePacks} (Test Path: #dynamic_json_widgets_test)",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Data Table
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Path')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: _files.map((file) {
                                  final name = file.uri.pathSegments.last;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(name)),
                                      DataCell(
                                        Text(
                                          file.path,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.play_arrow),
                                          onPressed: () {
                                            // TODO: Implement Run Logic
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ),
                if (!_isLoading && _files.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        l10n.noPacksFound,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
