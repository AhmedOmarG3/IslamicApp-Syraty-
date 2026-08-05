import 'package:flutter/material.dart';
import 'package:siraty/app/app.dart';
import 'package:siraty/app/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  runApp(
    const SiratyApp(),
  );
}
