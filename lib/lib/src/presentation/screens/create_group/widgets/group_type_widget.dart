import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/group_type.dart';

class GroupTypeWidget extends StatelessWidget {
  final String title;
  final GroupType value;
  GroupType? groupValue;
  final Function(GroupType value) onChanged;

  GroupTypeWidget({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.groupValue,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<GroupType>(
      title: Text(title.toUpperCase()),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: Colors.grey[300],
      dense: true,
      value: value,
      groupValue: groupValue,
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged:(value) => onChanged(value??GroupType.private),
    );
  }
}
