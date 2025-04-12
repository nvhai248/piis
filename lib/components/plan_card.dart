import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PlanCard extends StatelessWidget {
  final String date;
  final String petName;
  final String title;
  final String location;
  final Color backgroundColor;
  final VoidCallback? onLocationTap;

  const PlanCard({
    Key? key,
    required this.date,
    required this.petName,
    required this.title,
    required this.location,
    required this.backgroundColor,
    this.onLocationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$date • $petName',
            style: AppStyles.bodyText.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppStyles.titleSmall,
          ),
          Text(
            location,
            style: AppStyles.bodyText,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onLocationTap,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'View Location',
              style: AppStyles.bodyText.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 