import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSeeAll;

  const SectionContainer({
    super.key,
    required this.title,
    required this.child,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppStyles.titleMedium,
              ),
              TextButton(
                onPressed: onSeeAll ?? () {},
                child: Text(
                  'See All',
                  style: AppStyles.bodyText.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
