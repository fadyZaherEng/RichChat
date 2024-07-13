import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';

class AddMembers extends StatelessWidget {
  final GroupBloc bloc;
  final bool isAdmin;
  final Function() onTap;

  const AddMembers({
    super.key,
    required this.bloc,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "2 Members",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        !isAdmin
            ? const SizedBox.shrink()
            : Row(
                children: [
                  const Text(
                    "Add Members",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: onTap,
                    ),
                  )
                ],
              )
      ],
    );
  }
}
