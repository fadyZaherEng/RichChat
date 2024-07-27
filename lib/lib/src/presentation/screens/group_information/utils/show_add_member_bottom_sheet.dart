// show bottom sheet with the list of all app users to add them to the group
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/friends_list_widget.dart';

void showAddMembersBottomSheet({
  required BuildContext context,
  required List<String> groupMembersUIDs,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return PopScope(
        onPopInvoked: (bool didPop) async {
          if (!didPop) return;
          // do something when the bottom sheet is closed.
          await context.read<GroupBloc>().removeTempLists(isAdmins: false);
        },
        child: SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CupertinoSearchTextField(
                        onChanged: (value) {
                          // search for users
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<GroupBloc>()
                            .updateGroupDataInFireStoreIfNeeded()
                            .whenComplete(() {
                          // close bottom sheet
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.grey,
              ),
              Expanded(
                child: FriendsListWidget(
                  friendViewType: FriendViewType.groupView,
                  groupMembersUIDs: groupMembersUIDs,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
