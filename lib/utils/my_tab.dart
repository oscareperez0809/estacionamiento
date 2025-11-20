import 'package:flutter/material.dart';

class MyTab extends StatelessWidget {
  final String iconPath;
  final String iconName;
  const MyTab({super.key, required this.iconPath, required this.iconName});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono con borde negro
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Image.asset(
              iconPath,
              color: Colors.grey[600],
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            iconName,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            overflow: TextOverflow.ellipsis, // evita que el texto se desborde
          ),
        ],
      ),
    );
  }
}
