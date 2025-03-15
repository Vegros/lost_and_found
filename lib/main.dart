import 'package:flutter/material.dart';
import 'package:lost_and_found/noti_service.dart';
import 'package:lost_and_found/widgets/add_lost_item.dart';
import 'package:lost_and_found/widgets/found_items.dart';
import 'package:lost_and_found/widgets/main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotiService().initNotification();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost and Found',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainLayout(),
    );
  }
}
