import 'package:flutter/material.dart';
import 'about_us_header.dart';
import 'feature_grid.dart';
import 'explore_button.dart';

class AboutUsSection extends StatelessWidget {
  const AboutUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AboutUsHeader(),
              const SizedBox(height: 28),
              const FeatureGrid(),
              const SizedBox(height: 28),
              ExploreButton(
                onPressed: () {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}