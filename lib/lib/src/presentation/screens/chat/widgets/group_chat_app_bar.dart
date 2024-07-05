// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/group/group.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/group_member_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class GroupChatAppBar extends StatelessWidget {
  final String groupID;

  const GroupChatAppBar({
    super.key,
    required this.groupID,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Constants.groups)
          .doc(groupID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError||snapshot.data==null||!snapshot.data!.exists) {
          print(snapshot.error.toString());
          return Center(child: Text(snapshot.error.toString()));
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        if (snapshot.hasData) {
          final group =
              Group.fromMap(snapshot.data!.data()!);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    //TODO: navigate to group settings
                    context.read<GroupBloc>().updateGroupMembersList().whenComplete(() {
                      Navigator.pushNamed(
                          context, Routes.groupInformationScreen);
                    });
                  },
                  child: UserImageWidget(
                    image: group.groupLogo,
                    width: 40,
                    height: 40,
                    isBorder: false,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.groupName),
                        const SizedBox(
                          height: 5,
                        ),
                        GroupMemberWidget(membersUIDS: group.membersUIDS),
                      ],
                    ),
                  ),
                ),
                //TODO: add back arrow
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      textDirection: TextDirection.rtl,
                      color: Theme.of(context).iconTheme.color,
                      // textDirection: TextDirection.rtl,
                    )
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
