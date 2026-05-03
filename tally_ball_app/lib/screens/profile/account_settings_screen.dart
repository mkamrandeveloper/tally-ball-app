import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        titleTextStyle: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('PREFERENCES', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Dark Mode', style: TallyTextStyles.bodyLarge(context)),
            subtitle: Text('Toggle between dark and light themes', style: TallyTextStyles.bodySmall(context)),
            value: themeProvider.isDarkMode,
            activeColor: context.colors.precisionBlue,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          Divider(color: context.colors.border),
          ListTile(
            title: Text('Notifications', style: TallyTextStyles.bodyLarge(context)),
            trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
            onTap: () {},
          ),
          Divider(color: context.colors.border),
          ListTile(
            title: Text('Language', style: TallyTextStyles.bodyLarge(context)),
            trailing: Text('English', style: TallyTextStyles.bodyMedium(context)),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Text('ACCOUNT', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2)),
          const SizedBox(height: 16),
          ListTile(
            title: Text('Change Password', style: TallyTextStyles.bodyLarge(context)),
            trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
            onTap: () {},
          ),
          Divider(color: context.colors.border),
          ListTile(
            title: Text('Sign Out', style: TallyTextStyles.bodyLarge(context).copyWith(color: context.colors.warning)),
            leading: Icon(Icons.logout, color: context.colors.warning),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
          Divider(color: context.colors.border),
          ListTile(
            title: Text('Delete Account', style: TallyTextStyles.bodyLarge(context).copyWith(color: context.colors.error)),
            leading: Icon(Icons.delete_forever, color: context.colors.error),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
