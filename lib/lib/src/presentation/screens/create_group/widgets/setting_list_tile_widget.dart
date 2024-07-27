import 'dart:io';

import 'package:flutter/material.dart';

class SettingListTileWidget extends StatelessWidget {
  final String title;
  String? subtitle;
  final IconData icon;
  final Color iconColor;
  final void Function()? onTap;

  SettingListTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      leading: Container(
        decoration: BoxDecoration(
            color: iconColor, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white),
        ),
      ),
      trailing: Icon(
        Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_back_ios_new,
      ),
      onTap: onTap,
    );
  }
}
