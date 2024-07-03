import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/friends/friends_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/friend_widget.dart';

class FriendsListWidget extends StatefulWidget {
  final FriendViewType friendViewType;
  final String groupId;

  const FriendsListWidget({
    super.key,
    required this.friendViewType,
    required this.groupId,
  });

  @override
  State<FriendsListWidget> createState() => _FriendsListWidgetState();
}

class _FriendsListWidgetState extends State<FriendsListWidget> {
  List<UserModel> friends = [];

  FriendsBloc get _bloc => BlocProvider.of<FriendsBloc>(context);

  @override
  void initState() {
    super.initState();
    switch (widget.friendViewType) {
      case FriendViewType.friend:
        _bloc.add(GetFriends());
        break;
      case FriendViewType.groupView:
        // _bloc.add(GetGroups());
        break;
      case FriendViewType.friendRequest:
        _bloc.add(GetFriendsRequestsEvent(
          uid: FirebaseSingleTon.auth.currentUser!.uid,
          groupId: widget.groupId,
        ));
      default:
        break;
    }
    // friends.add(UserModel(
    //   name: 'Sefen',
    //   image:
    //       'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png',
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendsBloc, FriendsState>(listener: (context, state) {
      if (state is GetFriendsSuccess) {
        friends = state.friends;
      } else if (state is GetFriendsRequestsSuccess) {
        friends = state.friendsRequests;
      } else if (state is AcceptFriendRequestsSuccess) {
        CustomSnackBarWidget.show(
          context: context,
          message: S.of(context).friendRequestAccepted,
          path: ImagePaths.icSuccess,
          backgroundColor: ColorSchemes.green,
        );
      }
    }, builder: (context, state) {
      return friends.isEmpty
          ? Column(
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    S.of(context).noFriendsYet,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorSchemes.gray,
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: friends.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 15);
              },
              itemBuilder: (BuildContext context, int index) {
                return FriendWidget(
                  friend: friends[index],
                  friendViewType: widget.friendViewType,
                  groupId: widget.groupId,
                  onAcceptRequest: () {
                    //TODO: accept request
                    _bloc.add(
                        AcceptFriendRequestEvent(friendId: friends[index].uId));
                  },
                );
                //   ListTile(
                //   contentPadding: EdgeInsets.zero,
                //   onTap: () {
                //     Navigator.pushNamed(context, Routes.profileScreen,
                //         arguments: {"userId": friends[index].uId});
                //   },
                //   leading: UserImageWidget(
                //     image: friends[index].image,
                //     width: 50,
                //     height: 50,
                //   ),
                //   title: Text(
                //     friends[index].name,
                //     style: GoogleFonts.openSans(
                //       fontSize: 16,
                //       fontWeight: FontWeight.bold,
                //       color: ColorSchemes.black,
                //     ),
                //   ),
                //   subtitle: Text(
                //     friends[index].aboutMe,
                //     style: GoogleFonts.openSans(
                //       fontSize: 14,
                //       fontWeight: FontWeight.w400,
                //       color: ColorSchemes.black,
                //     ),
                //   ),
                //   trailing: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Theme.of(context).cardColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10.0),
                //       ),
                //     ),
                //     onPressed: () {
                //       if (widget.friendViewType ==
                //           FriendViewType.friendRequest) {
                //         //TODO: accept request
                //         _bloc.add(AcceptFriendRequestEvent(
                //             friendId: friends[index].uId));
                //       } else if (widget.friendViewType ==
                //           FriendViewType.friend) {
                //         //ToDO navigate to chat screen
                //         Navigator.pushNamed(
                //             context, Routes.chatWithFriendScreen,
                //             arguments: {
                //               "friendId": friends[index].uId,
                //               "friendName": friends[index].name,
                //               "friendImage": friends[index].image,
                //               "groupId": ""
                //             });
                //       }else {
                //         //check the checkbox
                //       }
                //     },
                //     child: Text(
                //       widget.friendViewType == FriendViewType.friend
                //           ? S.of(context).chat.toUpperCase()
                //           : S.of(context).accept.toUpperCase(),
                //       style: GoogleFonts.openSans(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //         color: Theme.of(context).colorScheme.primary,
                //       ),
                //     ),
                //   ),
                // );
              },
            );
    });
  }
}
