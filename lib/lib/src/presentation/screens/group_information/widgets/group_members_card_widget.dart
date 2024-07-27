import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_animated_dialog.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class GroupMembersCardWidget extends StatefulWidget {
  final bool isAdmin;
  final GroupBloc bloc;

  const GroupMembersCardWidget({
    super.key,
    required this.isAdmin,
    required this.bloc,
  });

  @override
  State<GroupMembersCardWidget> createState() => _GroupMembersCardWidgetState();
}

class _GroupMembersCardWidgetState extends State<GroupMembersCardWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Card(
          elevation: 2,
          child: Column(
            children: [
              FutureBuilder<List<UserModel>>(
                future: widget.bloc
                    .getGroupMembersDataFromFirestore(isAdmin: widget.isAdmin),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final member = snapshot.data![index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: UserImageWidget(
                            image: member.image,
                            width: 50,
                            height: 50,
                          ),
                          title: Text(member.name),
                          subtitle: Text(member.aboutMe),
                          trailing:
                              widget.bloc.group.adminsUIDS.contains(member.uId)
                                  ? const Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.orangeAccent,
                                    )
                                  : const SizedBox.shrink(),
                          onTap: () {
                            //show dialog to remove member
                            showAnimatedDialog(
                              context: context,
                              title: "Remove Member",
                              content:
                                  "Are you sure you want to remove ${member.name} from this group?",
                              textAction: "Remove",
                              onActionTap: (value,_) {
                                if (value) {
                                  //remove member from group
                                  widget.bloc.removeMemberFromGroup(groupMember: member);
                                  setState(() {});
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("No members yet"),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
