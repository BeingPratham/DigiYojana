import 'package:flutter/material.dart';
import 'package:digiyojana/home.dart';

void main() async {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, initialRoute: '/', routes: {
      '/': (context) => Home(),
      // '/detail': (context) => RouteTwo(),
    }),
  );
}
