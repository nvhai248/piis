import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'pets_screen.dart';
import 'services_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PetsScreen(),
    ServicesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Language toggle
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.language),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('English'),
                        leading: Radio<Locale>(
                          value: const Locale('en'),
                          groupValue: languageProvider.locale,
                          onChanged: (Locale? value) {
                            if (value != null) {
                              languageProvider.setLocale(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Tiếng Việt'),
                        leading: Radio<Locale>(
                          value: const Locale('vi'),
                          groupValue: languageProvider.locale,
                          onChanged: (Locale? value) {
                            if (value != null) {
                              languageProvider.setLocale(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Theme toggle
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 