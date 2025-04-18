import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/auth_service.dart';
import '../utils/message_utils.dart';
import '../models/user.dart';
import 'auth/login_screen.dart';
import 'profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authService.getCurrentProfile();
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _authService.signOut();
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: l10n.logoutSuccess,
          type: MessageType.success,
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: l10n.logoutError,
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> _navigateToEditProfile(UserProfile profile) async {
    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );

    if (updatedProfile != null && mounted) {
      setState(() {
        _profileFuture = Future.value(updatedProfile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loadingProfile),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.errorLoadingProfile,
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _profileFuture = _authService.getCurrentProfile();
                      });
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Semantics(
                          label: profile.avatarUrl != null
                              ? l10n.profilePicture
                              : l10n.profilePicturePlaceholder,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                              ),
                              color: theme.colorScheme.onPrimary,
                              tooltip: l10n.editProfile,
                              onPressed: () => _navigateToEditProfile(profile),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (profile.phoneNumber != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.phoneNumber!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Settings Section
              Text(
                l10n.settings,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    // Dark Mode Toggle
                    SwitchListTile(
                      title: Text(l10n.darkMode),
                      value: themeProvider.isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    const Divider(),
                    // Language Selection
                    ListTile(
                      title: Text(l10n.language),
                      trailing: DropdownButton<Locale>(
                        value: languageProvider.locale,
                        onChanged: (Locale? newValue) {
                          if (newValue != null) {
                            languageProvider.setLocale(newValue);
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: const Locale('en'),
                            child: Text(l10n.english),
                          ),
                          DropdownMenuItem(
                            value: const Locale('vi'),
                            child: Text(l10n.vietnamese),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(l10n.helpAndSupport),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(l10n.privacyPolicy),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        l10n.logout,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.logout),
                            content: Text(l10n.logoutConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleLogout();
                                },
                                child: Text(l10n.confirm),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}