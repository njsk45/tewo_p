import 'package:flutter/material.dart';

class PeripheralsPage extends StatefulWidget {
  const PeripheralsPage({super.key});

  @override
  State<PeripheralsPage> createState() => _PeripheralsPageState();
}

class _PeripheralsPageState extends State<PeripheralsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Peripherals Set Up'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ticket Printer', icon: Icon(Icons.print)),
              Tab(text: 'Barcode Scanner', icon: Icon(Icons.qr_code_scanner)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.print, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Ticket Printer Set Up - Coming Soon',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Barcode Scanner Set Up - Coming Soon',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
