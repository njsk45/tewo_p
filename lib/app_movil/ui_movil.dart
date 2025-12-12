//Mobile Interface
import 'dart:io';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:aws_common/aws_common.dart';
import 'package:flutter/material.dart';

class MainMovil extends StatelessWidget {
  const MainMovil({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello Bitch'))),
    );
  }
}
