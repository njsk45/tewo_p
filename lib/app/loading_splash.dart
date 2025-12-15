import 'package:flutter/material.dart';

class LoadingSplash extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;

  const LoadingSplash({
    super.key,
    this.message = "Loading...",
    this.backgroundColor,
    this.textColor,
  });

  /// Helper method to show the splash as a dialog
  static Future<void> show({
    required BuildContext context,
    String message = "Loading...",
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingSplash(message: message),
    );
  }

  /// Helper method to hide the splash
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme if not provided
    final theme = Theme.of(context);
    final bgColor =
        backgroundColor ?? theme.scaffoldBackgroundColor.withOpacity(0.95);
    final txtColor =
        textColor ?? theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: Colors
          .transparent, // Allow dialog barrier to show if needed or handle opacity here
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium looking loader
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message,
              style: TextStyle(
                color: txtColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
