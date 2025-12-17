import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tewo_p/l10n/app_localizations.dart';
import 'package:tewo_p/main.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tewo_p/services/preferences_service.dart';

class MainSetupPage extends StatelessWidget {
  const MainSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isDesktop)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: 'Fullscreen',
              onPressed: () async {
                bool isFullscreen = await windowManager.isFullScreen();
                await windowManager.setFullScreen(!isFullscreen);
                PreferencesService().saveFullscreen(!isFullscreen);
              },
            ),
          const SizedBox(width: 8),
        ],
        leading: IconButton(
          icon: const Icon(Icons.language),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.languageDialogTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('English'),
                      onTap: () {
                        MainApp.setLocale(context, const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Español'),
                      onTap: () {
                        MainApp.setLocale(context, const Locale('es'));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.welcomeTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.setupSubtitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color.fromARGB(255, 117, 117, 117),
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.comingSoon),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: Text(AppLocalizations.of(context)!.createBusiness),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.comingSoon),
                  ),
                );
              },
              icon: const Icon(Icons.login_outlined),
              label: Text(AppLocalizations.of(context)!.existingBusiness),
            ),
          ],
        ),
      ),
    );
  }
}
