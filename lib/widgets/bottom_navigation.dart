import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.pets_outlined),
          selectedIcon: const Icon(Icons.pets),
          label: l10n.pets,
        ),
        NavigationDestination(
          icon: const Icon(Icons.medical_services_outlined),
          selectedIcon: const Icon(Icons.medical_services),
          label: l10n.services,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
    );
  }
} 