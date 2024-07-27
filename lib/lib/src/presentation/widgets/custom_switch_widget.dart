import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';

class CustomSwitchWidget extends StatefulWidget {
  final bool value;
  final void Function(bool value) onChanged;
  final String title;
  final String? subtitle;
  final String? pathImage;

  const CustomSwitchWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.pathImage,
  });

  @override
  State<CustomSwitchWidget> createState() => _CustomSwitchWidgetState();
}

class _CustomSwitchWidgetState extends State<CustomSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: widget.value,
      onChanged: widget.onChanged,
      title: Text(widget.title),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
      secondary: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.value ? ColorSchemes.white :Theme.of(context).colorScheme.primary,

      ),
        child: Icon(
          widget.value ? Icons.nightlight_rounded : Icons.wb_sunny_rounded,
          color: widget.value ? Theme.of(context).colorScheme.primary : ColorSchemes.white,
        ),
      )
    );
  }
}
