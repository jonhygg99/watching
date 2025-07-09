import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:watching/main.dart';

void main() {
  patrolTest('Basic app smoke test', (tester) async {
    // 1. Launch the app
    await tester.pumpWidgetAndSettle(const MyApp());

    debugDumpApp();
  });
}
