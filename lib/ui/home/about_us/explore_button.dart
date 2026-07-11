import 'package:flutter/material.dart';

class ExploreButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ExploreButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Khám phá thêm về Travol',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}