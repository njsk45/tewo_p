//Desktop Interface
import 'dart:io';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:aws_common/aws_common.dart';
import 'package:flutter/material.dart';

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
