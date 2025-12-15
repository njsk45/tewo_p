import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class DynamicUiService {
  // Hardcoded test path for now as per previous context
  // Hardcoded test path for now as per previous context
  static const String testPath =
      r'c:\Users\Arzeuk\Documents\Code Projects\tewo_p\#dynamic_json_widgets_test';

  Future<Widget?> loadJsonWidget(
    String fileName,
    BuildContext context, {
    JsonWidgetRegistry? registry,
  }) async {
    try {
      final file = File('$testPath\\$fileName');
      if (!await file.exists()) {
        print("Dynamic UI File not found: ${file.path}");
        return null; // Return null to trigger fallback
      }

      final content = await file.readAsString();
      final jsonData = jsonDecode(content);

      // Use provided registry or default instance
      final reg = registry ?? JsonWidgetRegistry.instance;
      final widgetData = JsonWidgetData.fromDynamic(jsonData, registry: reg);

      return widgetData.build(context: context);
    } catch (e) {
      print("Error loading dynamic widget: $e");
      return Center(
        child: Text(
          "Error loading dynamic UI:\n$e",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }
}
