import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pop/main.dart';
import 'package:pop/services/haptic_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _hapticService = HapticService();
  bool _isHapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadHapticSetting();
  }

  Future<void> _loadHapticSetting() async {
    await _hapticService.init();
    if (mounted) {
      setState(() {
        _isHapticEnabled = _hapticService.isHapticEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: const Text("Light / Dark Mode"),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            ListTile(
              title: const Text("Haptic Feedback"),
              trailing: Switch(
                value: _isHapticEnabled,
                onChanged: (value) async {
                  await _hapticService.setHapticEnabled(value);
                  if (mounted) {
                    setState(() {
                      _isHapticEnabled = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
