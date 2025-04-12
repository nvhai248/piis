import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PetCareCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double distance;
  final double rating;
  final VoidCallback? onLocationTap;
  final Color backgroundColor;

  const PetCareCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.distance,
    required this.rating,
    this.onLocationTap,
    this.backgroundColor = Colors.yellow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppStyles.titleSmall,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        Text(
                          '$distance km',
                          style: AppStyles.bodyText,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        Text(
                          rating.toString(),
                          style: AppStyles.bodyText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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