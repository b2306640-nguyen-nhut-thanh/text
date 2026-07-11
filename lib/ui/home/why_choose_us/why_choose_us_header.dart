import 'package:flutter/material.dart';

class WhyChooseUsHeader extends StatelessWidget {
  const WhyChooseUsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TẠI SAO NÊN CHỌN TRAVOL',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                fontSize: 18,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 45,
          height: 3,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}