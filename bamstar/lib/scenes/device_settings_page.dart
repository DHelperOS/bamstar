import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/theme/typography.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정', style: context.h1),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('일반', style: context.h2),
              const SizedBox(height: 16),
              _tile(
                context,
                icon: Icon(SolarIconsOutline.magnifier),
                title: '언어',
                trailing: Icon(SolarIconsOutline.arrowRight, size: 18),
                onTap: () => _toast(context, '언어 설정'),
              ),
              const SizedBox(height: 8),
              _tile(
                context,
                icon: Icon(SolarIconsOutline.bell),
                title: '알림',
                trailing: Switch.adaptive(
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                onTap: () => setState(() => _notifications = !_notifications),
              ),
              const SizedBox(height: 8),
              _tile(
                context,
                icon: Icon(SolarIconsOutline.moon),
                title: '다크 모드',
                trailing: Switch.adaptive(
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                onTap: () => setState(() => _darkMode = !_darkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required Widget icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconTheme.merge(
              data: const IconThemeData(size: 20),
              child: icon,
            ),
          ),
        ),
        title: Text(
          title,
          style: context.lead.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        trailing: trailing,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
