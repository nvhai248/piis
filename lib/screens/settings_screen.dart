import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'English';
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _language = prefs.getString('language') ?? 'English';
      _currency = prefs.getString('currency') ?? 'USD';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('darkMode', _darkModeEnabled);
    await prefs.setString('language', _language);
    await prefs.setString('currency', _currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Notifications',
            [
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive notifications about your pets and orders',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            'Appearance',
            [
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Enable dark theme',
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            'Language',
            [
              _buildSettingTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: _language,
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showLanguageDialog,
              ),
            ],
          ),
          _buildSection(
            'Currency',
            [
              _buildSettingTile(
                icon: Icons.attach_money,
                title: 'Currency',
                subtitle: _currency,
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showCurrencyDialog,
              ),
            ],
          ),
          _buildSection(
            'About',
            [
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              _buildSettingTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {
                  // Navigate to Terms of Service
                },
              ),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Learn about our privacy practices',
                onTap: () {
                  // Navigate to Privacy Policy
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('USD'),
            _buildCurrencyOption('EUR'),
            _buildCurrencyOption('GBP'),
            _buildCurrencyOption('JPY'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _language == language
          ? Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        setState(() {
          _language = language;
        });
        _saveSettings();
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCurrencyOption(String currency) {
    return ListTile(
      title: Text(currency),
      trailing: _currency == currency
          ? Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        setState(() {
          _currency = currency;
        });
        _saveSettings();
        Navigator.pop(context);
      },
    );
  }
} 