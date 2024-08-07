import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/friends/friends_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class FriendWidget extends StatefulWidget {
  final UserModel friend;
  final FriendViewType friendViewType;
  final void Function()? onAcceptRequest;
  bool? isAdminView;
  final String groupId;

  FriendWidget({
    super.key,
    required this.friend,
    required this.friendViewType,
    required this.groupId,
    this.onAcceptRequest,
    this.isAdminView,
  });

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  FriendsBloc get _bloc => BlocProvider.of<FriendsBloc>(context);

  GroupBloc get _groupBloc => BlocProvider.of<GroupBloc>(context);

  bool _checkUserIsMemberList() {
    return widget.isAdminView != null && widget.isAdminView!
        ? context.read<GroupBloc>().groupAdminsList.contains(widget.friend)
        : context.read<GroupBloc>().groupMembersList.contains(widget.friend);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendsBloc, FriendsState>(
      listener: (context, state) {
        if (state is AcceptFriendRequestsSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).friendRequestAccepted,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        }
      },
      builder: (context, state) {
        return _buildFriendWidget(context);
      },
    );
  }

  Widget _buildFriendWidget(BuildContext context) {
    //get uid
    final uid = FirebaseSingleTon.auth.currentUser!.uid;
    String name =
        uid == widget.friend.uId ? S.of(context).you : widget.friend.name;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        _onTap(context);
      },
      leading: UserImageWidget(
        image: widget.friend.image,
        width: 50,
        height: 50,
      ),
      title: Text(name),
      subtitle: Text(
        widget.friend.aboutMe,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildTrailing(context),
    );
  }

  void _onTap(BuildContext context) {
    if (widget.friendViewType == FriendViewType.friend) {
      //ToDO navigate to chat screen
      Navigator.pushNamed(
        context,
        Routes.chatWithFriendScreen,
        arguments: {
          "friendId": widget.friend.uId,
          "friendName": widget.friend.name,
          "friendImage": widget.friend.image,
          "groupId": ""
        },
      );
    } else if (widget.friendViewType == FriendViewType.allUsers) {
      Navigator.pushNamed(
        context,
        Routes.profileScreen,
        arguments: {
          "userId": widget.friend.uId,
        },
      );
    } else {
      //check The Checkbox
      if (widget.groupId.isNotEmpty) {
        Navigator.pushNamed(
          context,
          Routes.profileScreen,
          arguments: {
            "userId": widget.friend.uId,
          },
        );
      }
    }
  }

  _buildTrailing(BuildContext context) {
    return widget.friendViewType == FriendViewType.friendRequest
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
            onPressed: () {
              //TODO: accept request
              if (widget.groupId.isEmpty) {
                //not in group
                _bloc.add(AcceptFriendRequestEvent(
                  friendId: widget.friend.uId,
                ));
              } else {
                //in group
                _groupBloc
                    .acceptRequestToJoinGroup(
                        groupId: widget.groupId, uid: widget.friend.uId)
                    .whenComplete(() {
                  CustomSnackBarWidget.show(
                    context: context,
                    message: "${widget.friend.name} is now your group member",
                    path: ImagePaths.icSuccess,
                    backgroundColor: ColorSchemes.green,
                  );
                });
              }
              // if (widget.onAcceptRequest != null) widget.onAcceptRequest!();
            },
            child: Text(
              S.of(context).accept.toUpperCase(),
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        : widget.friendViewType == FriendViewType.groupView
            ? BlocConsumer<GroupBloc, GroupState>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  return Checkbox(
                    value: _checkUserIsMemberList(),
                    onChanged: (value) {
                      //TODO: check the checkbox
                      if (widget.isAdminView != null && widget.isAdminView!) {
                        if (value != null && value) {
                          _groupBloc.addMemberToAdmin(groupAdmin: widget.friend);
                        } else {
                          _groupBloc.removeAdminFromAdmins(groupAdmin: widget.friend);
                        }
                      } else {
                        if (value != null && value) {
                          _groupBloc.addMemberToGroup(groupMember: widget.friend);
                        } else {
                          _groupBloc.removeMemberFromGroup(groupMember: widget.friend);
                        }
                      }
                    },
                  );
                },
              )
            : null;
  }
}
