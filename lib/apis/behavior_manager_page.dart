import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tewo_p/l10n/manual_localizations.dart';
import 'package:tewo_p/services/bp_service.dart';
import 'package:tewo_p/app/loading_splash.dart';
import 'package:tewo_p/services/db_instruction_service.dart';
import 'package:tewo_p/apis/business_setup_page.dart';
import 'package:permission_handler/permission_handler.dart';

// -----------------------------------------------------------------------------
// PHASE 3B: BEHAVIOR MANAGER PAGE
// -----------------------------------------------------------------------------
class BehaviorManagerPage extends StatefulWidget {
  const BehaviorManagerPage({super.key});

  @override
  State<BehaviorManagerPage> createState() => _BehaviorManagerPageState();
}

class _BehaviorManagerPageState extends State<BehaviorManagerPage> {
  List<dynamic> _packs = [];
  bool _isLoading = true;

  static String _getRootDir() {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Documents/dynamic_json_widgets_test/dynamic_json_bp_repository';
    }
    final home = Platform.environment['HOME'] ?? '/home/night';
    return '$home/Documents/Code/TeWo/TeWo-P/dynamic_json_widgets_test/dynamic_json_bp_repository';
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  static Future<bool> checkAndroidPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    if (!status.isGranted) {
      // Fallback/Alternative for older Android or specific scopes
      var storage = await Permission.storage.status;
      if (!storage.isGranted) {
        storage = await Permission.storage.request();
      }
      if (!storage.isGranted && !status.isGranted) {
        print("Storage permission denied");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Storage permission required for test path"),
            ),
          );
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _loadFiles() async {
    try {
      if (!await checkAndroidPermissions(context)) {
        setState(() => _isLoading = false);
        return;
      }

      final rootDir = _getRootDir();
      final contentsFile = File('$rootDir/contents.json');

      print('DEBUG: rootDir=$rootDir');
      print('DEBUG: targetFile=${contentsFile.path}');

      if (await contentsFile.exists()) {
        final content = await contentsFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);

        final List<Map<String, dynamic>> enrichedPacks = [];
        for (var item in jsonList) {
          final pack = Map<String, dynamic>.from(item);
          final manifestPath = '$rootDir/${item["manifest"]}';
          final manifestFile = File(manifestPath);
          if (await manifestFile.exists()) {
            try {
              final manifestContent = await manifestFile.readAsString();
              final manifestJson = jsonDecode(manifestContent);
              pack['author'] = manifestJson['author'];
              pack['tags'] = manifestJson['tags'];
              pack['version'] =
                  manifestJson['version']; // Capture version if available
            } catch (e) {
              print('Error reading manifest: $e');
            }
          }
          enrichedPacks.add(pack);
        }

        setState(() {
          _packs = enrichedPacks;
          _isLoading = false;
        });
      } else {
        print('contents.json NOT FOUND at ${contentsFile.path}');
        // Debugging: List the parent directory
        final parentDir = Directory(rootDir);
        if (await parentDir.exists()) {
          print('Directory $rootDir exists. Contents:');
          try {
            await for (var entity in parentDir.list()) {
              print(' - ${entity.path}');
            }
          } catch (e) {
            print('Error listing dir: $e');
          }
        } else {
          print('Directory $rootDir does NOT exist.');
          print('CWD: ${Directory.current.path}');
        }

        setState(() => _packs = []);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading packs from contents.json: $e");
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
                        setState(() => _isLoading = true);
                        _loadFiles(); // Refresh
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Table Title
                Text(
                  "${l10n.availablePacks} (Test Path: dynamic_json_widgets_test)",
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
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Author')),
                                  DataColumn(label: Text('Tags')),
                                ],
                                rows: _packs.map((pack) {
                                  final name = pack['name'] ?? 'Unknown';
                                  final author =
                                      pack['author']?.toString() ?? '-';
                                  final tags =
                                      (pack['tags'] as List?)?.join(', ') ??
                                      '-';

                                  return DataRow(
                                    onSelectChanged: (_) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BehaviorPackDetailsPage(
                                                pack: pack,
                                              ),
                                        ),
                                      );
                                    },
                                    cells: [
                                      DataCell(Text(name)),
                                      DataCell(Text(author)),
                                      DataCell(Text(tags)),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ),
                if (!_isLoading && _packs.isEmpty)
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

class BehaviorPackDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pack;
  const BehaviorPackDetailsPage({super.key, required this.pack});

  @override
  State<BehaviorPackDetailsPage> createState() =>
      _BehaviorPackDetailsPageState();
}

class _BehaviorPackDetailsPageState extends State<BehaviorPackDetailsPage> {
  String _descriptionText = "Loading description...";

  @override
  void initState() {
    super.initState();
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    final rootDir = _BehaviorManagerPageState._getRootDir();

    // Defer locale check to context availability or pass it
    // But we are in State, so we can access context in build or use simple logic here if ready.
    // However, context is not valid in initState for inherited widgets unless in didChangeDependencies.
    // We'll call a method from didChangeDependencies or build.
    // For now, let's just trigger it slightly later.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _fetchDescriptionText(rootDir),
    );
  }

  Future<void> _fetchDescriptionText(String rootDir) async {
    final locale = Localizations.localeOf(context).languageCode;
    String? descPath;

    if (locale == 'es') {
      descPath = widget.pack['description_es'];
    }

    // Fallback or default to 'description' (en)
    if (descPath == null || descPath.isEmpty) {
      descPath = widget.pack['description'];
    }

    if (descPath != null) {
      final file = File('$rootDir/$descPath');
      if (await file.exists()) {
        final text = await file.readAsString();
        if (mounted) {
          setState(() {
            _descriptionText = text;
          });
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _descriptionText = "Description not available.";
      });
    }
  }

  Future<void> _handleUseTemplate() async {
    // Check permissions first
    if (!await _BehaviorManagerPageState.checkAndroidPermissions(context))
      return;

    // Show splash screen
    LoadingSplash.show(context: context, message: "Unpacking Template...");

    try {
      final srcRootDir = _BehaviorManagerPageState._getRootDir();
      // On Android, we might need a different dest dir too, but for now assuming same structure or app documents dir.
      // Actually, user only specified test path for reading. Let's keep destDir logic or use app docs dir.
      // For now, let's just fix srcRootDir.

      final String destDir;
      if (Platform.isAndroid) {
        // Use a temp or documents path for extraction test
        destDir = '/storage/emulated/0/Documents/dynamic_json_widgets_test/bp';
      } else {
        final home = Platform.environment['HOME'] ?? '/home/night';
        destDir =
            '$home/Documents/Code/TeWo/TeWo-P/dynamic_json_widgets_test/bp';
      }

      // Locate .twbp file
      // Strategy: look in the same folder as manifest.json
      final manifestRelPath =
          widget.pack['manifest']; // e.g. folder/v1.0.0/manifest.json
      if (manifestRelPath == null) throw Exception("Manifest path missing");

      final manifestFile = File('$srcRootDir/$manifestRelPath');
      final parentDir = manifestFile.parent;

      if (!await parentDir.exists())
        throw Exception("Pack directory not found");

      // Find .twbp file
      File? twbpFile;
      await for (var entity in parentDir.list()) {
        if (entity is File && entity.path.toLowerCase().endsWith('.twbp')) {
          twbpFile = entity;
          break;
        }
      }

      if (twbpFile == null)
        throw Exception(".twbp file not found in ${parentDir.path}");

      await BpService.extractBehaviorPack(
        twbpFile.path,
        destinationDir: destDir,
      );

      // Read db.instructions.json from path specified in contents.json
      final dbInstructionsRelPath = widget.pack['db_instructions'];
      String dbInstructionsPath;

      if (dbInstructionsRelPath != null) {
        dbInstructionsPath = '$srcRootDir/$dbInstructionsRelPath';
      } else {
        // Fallback to legacy structure if missing
        dbInstructionsPath = '${parentDir.parent.path}/db.instructions.json';
        print(
          "Warning: db_instructions not found in pack config, trying legacy: $dbInstructionsPath",
        );
      }

      final dbInstructionsFileCorrect = File(dbInstructionsPath);

      Map<String, dynamic> dbInstructions = {};

      if (await dbInstructionsFileCorrect.exists()) {
        dbInstructions = await DbInstructionService().parseInstructions(
          dbInstructionsPath,
        );
      } else {
        print("Warning: db.instructions.json not found at $dbInstructionsPath");
      }

      // Read manifest content to pass to setup page
      Map<String, dynamic> manifestData = {};
      // Reuse manifestRelPath from earlier
      if (manifestRelPath != null) {
        final manifestFile = File('$srcRootDir/$manifestRelPath');
        if (await manifestFile.exists()) {
          try {
            manifestData = jsonDecode(await manifestFile.readAsString());
          } catch (e) {
            print('Error reading manifest content: $e');
          }
        }
      }

      // Hide splash
      if (mounted) {
        LoadingSplash.hide(context);

        // Navigate to Business Setup
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessSetupPage(
              packInstructions: dbInstructions,
              packPath: destDir, // Passing where it was extracted
              manifest: manifestData,
            ),
          ),
        );
      }
    } catch (e) {
      // Hide splash on error
      if (mounted) {
        LoadingSplash.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.pack['name'] ?? 'Unknown Pack';
    final author = widget.pack['author'] ?? 'Unknown Author';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              "By $author",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text("Description", style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _descriptionText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleUseTemplate,
                child: const Text("Use Template"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
