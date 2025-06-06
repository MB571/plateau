import 'package:flutter/material.dart';

class ClimbsPage extends StatelessWidget {
  const ClimbsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: const Center(child: Text('Your generated plan will appear here')),
    );
  }
}
