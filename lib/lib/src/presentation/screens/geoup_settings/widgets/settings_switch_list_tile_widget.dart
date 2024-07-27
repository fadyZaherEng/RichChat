import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsSwitchListTileWidget extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;

  const SettingsSwitchListTileWidget({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.roboto(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: (value) => onChanged(value),
        secondary: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child:  Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
