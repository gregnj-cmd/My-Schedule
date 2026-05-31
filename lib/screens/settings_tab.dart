import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/schedule_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  ListTile(
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const Divider(),
                  const ListTile(
                    title: Text('Accent Color'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _colorOption(context, themeProvider, Colors.blue),
                        _colorOption(context, themeProvider, Colors.purple),
                        _colorOption(context, themeProvider, Colors.orange),
                        _colorOption(context, themeProvider, Colors.green),
                        _colorOption(context, themeProvider, Colors.redAccent),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'Data Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Reset All Data'),
            textColor: Colors.red,
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _showResetConfirmation(context),
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'Smart Schedule 2.0',
            applicationVersion: '2.0.0',
            applicationLegalese: '© 2026 Smart Planner Team',
          ),
        ],
      ),
    );
  }

  Widget _colorOption(BuildContext context, ThemeProvider provider, Color color) {
    bool isSelected = provider.accentColor.value == color.value;
    return GestureDetector(
      onTap: () => provider.setAccentColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!, width: 3) : null,
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Everything?'),
        content: const Text('This will delete all your scheduled events. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // We'll just delete them all in the provider
              final provider = Provider.of<ScheduleProvider>(context, listen: false);
              for (var event in provider.events) {
                provider.deleteEvent(event.id);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
