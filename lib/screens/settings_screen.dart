import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('App'),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About G1 Ready',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAbout(context),
              ),
              _buildSettingsTile(
                icon: Icons.star_outline,
                title: 'Rate the App',
                subtitle: 'Enjoying G1 Ready? Leave a review!',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Progress'),
              _buildSettingsTile(
                icon: Icons.refresh,
                title: 'Reset Progress',
                subtitle: 'Clear all XP, scores and bookmarks',
                onTap: () => _confirmReset(context),
                color: AppTheme.incorrect,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Legal'),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Use',
                subtitle: 'App terms and conditions',
                onTap: () {},
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.drive_eta, size: 48, color: AppTheme.canadianRed),
                    const SizedBox(height: 8),
                    const Text('G1 Ready 🍁',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
                    const SizedBox(height: 4),
                    const Text('Ontario Driver\'s Test Prep',
                        style: TextStyle(fontSize: 13, color: AppTheme.mediumGrey)),
                    const SizedBox(height: 4),
                    const Text('Version 1.0.0',
                        style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.mediumGrey)),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = AppTheme.darkGrey,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGrey, width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.mediumGrey),
        onTap: onTap,
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About G1 Ready'),
        content: const Text(
          'G1 Ready helps Ontario drivers prepare for their G1 knowledge test.\n\n'
          '80 practice questions across 8 topics, exam simulation mode, and progress tracking.\n\n'
          'Good luck on your test! 🍁',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.canadianRed)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will clear all your XP, scores, bookmarks and badges. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress reset successfully'),
                  backgroundColor: AppTheme.canadianRed,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: AppTheme.incorrect)),
          ),
        ],
      ),
    );
  }
}
