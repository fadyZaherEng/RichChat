import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_animated_dialog.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class GroupCardDetailsWidget extends StatelessWidget {
  final GroupBloc bloc;
  final bool isAdmin;

  const GroupCardDetailsWidget({
    super.key,
    required this.bloc,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {},
                  child: UserImageWidget(
                    image: bloc.group.groupLogo,
                    width: 80,
                    height: 80,
                    isBorder: false,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bloc.group.groupName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: isAdmin
                              ? null
                              : () {
                                  // show dialog to change group type
                                  showAnimatedDialog(
                                    context: context,
                                    title: "Change Group Type",
                                    content:
                                        "Are You Sure want to change the group type to: ${bloc.group.isPrivate ? "Public" : "Private"}",
                                    textAction: "Change",
                                    onActionTap: (value) {
                                      //change group type
                                      bloc.changeGroupType();
                                    },
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              color: isAdmin ? Colors.deepPurple : Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              bloc.group.isPrivate
                                  ? S.of(context).private
                                  : S.of(context).public,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        _getRequestWidget(context, isAdmin),
                      ],
                    )
                  ],
                )
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Text(
              S.of(context).groupDescription,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              bloc.group.groupDescription,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getRequestWidget(BuildContext context, bool isAdmin) {
    if (isAdmin) {
      if (bloc.group.awaitingApprovalUIDS.isNotEmpty) {
        return InkWell(
          onTap: () {
            //navigate to add members screen
            Navigator.pushNamed(
              context,
              Routes.friendRequestScreen,
              arguments: {
                "groupId": bloc.group.groupID,
              },
            );
          },
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orangeAccent,
            child: Icon(
              Icons.person_add,
              color: Colors.white,
              size: 15,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
    return const SizedBox.shrink();
  }
}
