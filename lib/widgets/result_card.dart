import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const ResultCard({required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
