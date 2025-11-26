//Desktop Interface
import 'dart:io';
import 'package:tewo_p/app_desktop/dblib.dart';
import 'package:flutter/material.dart';

AppDatabase tewodb = AppDatabase();

class MainDesktop extends StatelessWidget {
  const MainDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeWo-P',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
