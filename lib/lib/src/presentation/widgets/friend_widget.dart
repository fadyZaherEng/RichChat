import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
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

  FriendWidget({
    super.key,
    required this.friend,
    required this.friendViewType,
    this.onAcceptRequest,
    this.isAdminView,
  });

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  FriendsBloc get _bloc => BlocProvider.of<FriendsBloc>(context);

  bool _checkUserIsMemberList() {
    return widget.isAdminView!
        ? context.read<GroupBloc>().groupAdminsList.contains(widget.friend)
        : context.read<GroupBloc>().groupMembersList.contains(widget.friend);
    // return BlocProvider.of<GroupBloc>(context).groupMembersList.contains(widget.friend);
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        _onTap(context);
      },
      leading:
          UserImageWidget(image: widget.friend.image, width: 50, height: 50),
      title: Text(
        widget.friend.name,
        style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorSchemes.black,
        ),
      ),
      subtitle: Text(
        widget.friend.aboutMe,
        style: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ColorSchemes.black,
        ),
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
    }
  }

  _buildTrailing(BuildContext context) {
    return widget.friendViewType == FriendViewType.friendRequest
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            onPressed: () {
              //TODO: accept request
              _bloc.add(AcceptFriendRequestEvent(friendId: widget.friend.uId));
              // if (widget.onAcceptRequest != null) widget.onAcceptRequest!();
            },
            child: Text(S.of(context).accept.toUpperCase(),
                style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)))
        : widget.friendViewType == FriendViewType.groupView
            ? Checkbox(
                value: _checkUserIsMemberList(),
                onChanged: (value) {
                  //TODO: check the checkbox
                  if (widget.isAdminView != null && widget.isAdminView!) {
                    if (value != null && value) {
                      context
                          .read<GroupBloc>()
                          .addMemberToAdmin(groupAdmin: widget.friend);
                    } else {
                      context
                          .read<GroupBloc>()
                          .removeAdminFromAdmins(user: widget.friend);
                    }
                  } else {
                    if (value != null && value) {
                      context
                          .read<GroupBloc>()
                          .addMemberToGroup(groupMember: widget.friend);
                    } else {
                      context
                          .read<GroupBloc>()
                          .removeMemberFromGroup(user: widget.friend);
                    }
                  }
                },
              )
            : null;
  }
}
