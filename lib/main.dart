import 'package:flutter/material.dart';
import 'package:plateau_app/pages/welcome_page.dart';
import 'package:plateau_app/pages/plan_page.dart';

void main() {
  runApp(const PlateauApp());
}

class PlateauApp extends StatelessWidget {
  const PlateauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plateau',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Baumans',
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/welcome',
      onGenerateRoute: (settings) {
        if (settings.name == '/plan') {
          final plan = settings.arguments as List<dynamic>;
          return MaterialPageRoute(
            builder: (context) => PlanPage(plan: plan),
          );
        }

        return MaterialPageRoute(
          builder: (context) => const WelcomePage(),
        );
      },
    );
  }
}
