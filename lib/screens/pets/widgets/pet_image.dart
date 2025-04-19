import 'package:flutter/material.dart';
import '../../../models/pet.dart';

class PetImage extends StatelessWidget {
  final Pet pet;
  final double size;

  const PetImage({
    super.key,
    required this.pet,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Hero(
        tag: 'pet_image_${pet.id}',
        child: Semantics(
          label: pet.mainPicture != null ? '${pet.name} photo' : '${pet.name} placeholder icon',
          image: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: pet.mainPicture != null
                ? Image.network(
                    pet.mainPicture!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
                  )
                : _buildPlaceholder(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.pets,
        size: size * 0.32,
        color: theme.colorScheme.primary,
      ),
    );
  }
} 