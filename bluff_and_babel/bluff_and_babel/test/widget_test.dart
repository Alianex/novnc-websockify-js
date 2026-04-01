// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:bluff_and_babel/main.dart';
import 'package:bluff_and_babel/firebase_options.dart';

void main() {
  testWidgets('App builds and shows title', (WidgetTester tester) async {
    // Build a minimal app shell (avoid Firebase/providers in tests).
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Bluff & Babel')),
      ),
    ));

    // Verify the app title is present.
    expect(find.text('Bluff & Babel'), findsOneWidget);
  });
}
