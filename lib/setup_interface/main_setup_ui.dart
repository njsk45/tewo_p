import 'package:flutter/material.dart';
import 'package:tewo_p/l10n/app_localizations.dart';

class MainSetupPage extends StatelessWidget {
  const MainSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
