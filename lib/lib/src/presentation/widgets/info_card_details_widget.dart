import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_action_dialog.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_animated_dialog.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/profile/profile_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class InfoCardDetailsWidget extends StatefulWidget {
  final GroupBloc? groupProvider;
  final bool? isAdmin;
  final UserModel? userModel;
  final File? fileImage;
  final Function() onTapUpdateProfile;

  const InfoCardDetailsWidget({
    super.key,
    this.groupProvider,
    this.isAdmin,
    this.userModel,
    this.fileImage,
    required this.onTapUpdateProfile,
  });

  @override
  State<InfoCardDetailsWidget> createState() => _InfoCardDetailsWidgetState();
}

class _InfoCardDetailsWidgetState extends State<InfoCardDetailsWidget> {
  ProfileBloc get _bloc => BlocProvider.of<ProfileBloc>(context);

  @override
  Widget build(BuildContext context) {
    //get profile image
    final profileImage = widget.userModel != null
        ? widget.userModel!.image
        : widget.groupProvider!.group.groupLogo;
    //get profile name
    final profileName = widget.userModel != null
        ? widget.userModel!.name
        : widget.groupProvider!.group.groupName;
    //get profile about me
    final profileAboutMe = widget.userModel != null
        ? widget.userModel!.aboutMe
        : widget.groupProvider!.group.groupDescription;
    //get current user
    final currentUser = GetUserUseCase(injector())();
    // get isGroup
    final isGroup = widget.userModel != null ? false : true;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: widget.userModel != null &&
                          widget.userModel!.uId != currentUser.uId
                          ? null
                          : widget.onTapUpdateProfile,
                      child: UserImageWidget(
                        image: profileImage,
                        fileImage: widget.fileImage,
                        width: 80,
                        height: 80,
                        isBorder: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              profileName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            _getEditWidget(
                              title: 'Change Name',
                              content: Constants.changeName,
                              profileName: profileName,
                              aboutMe: profileAboutMe,
                              uid: currentUser.uId,
                              isAdmin: widget.isAdmin,
                              isGroup: isGroup,
                            ),
                          ],
                        ),
                        // display phone number
                        widget.userModel != null &&
                            currentUser.uId == widget.userModel!.uId
                            ? Text(
                          //get current user phone number
                          currentUser.phoneNumber,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            : const SizedBox.shrink(),
                        const SizedBox(height: 5),
                        widget.userModel != null
                            ? ProfileStatusWidget(
                          userModel: widget.userModel!,
                          currentUser: currentUser,
                        )
                            : GroupStatusWidget(
                          isAdmin: widget.isAdmin!,
                          groupProvider: widget.groupProvider!,
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.userModel != null
                          ? S.of(context).aboutMe
                          : 'Group Description',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _getEditWidget(
                      title: 'Change Name',
                      content: Constants.changeDes,
                      profileName: profileName,
                      aboutMe: profileAboutMe,
                      uid: currentUser.uId,
                      isAdmin: widget.isAdmin,
                      isGroup: isGroup,
                    ),
                  ],
                ),
                Text(
                  profileAboutMe,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getEditWidget({
    required String title,
    required String content,
    bool? isAdmin,
    required bool isGroup,
    required String profileName,
    required String aboutMe,
    required String uid,
  }) {
    if (isGroup) {
      // check if user is admin
      if (isAdmin!) {
        return InkWell(
          onTap: () {
            showAnimatedDialog(
              context: context,
              title: title,
              content: content,
              textAction: "Change",
              onActionTap: (value, updatedText) async {
                if (value) {
                  if (content == Constants.changeName) {
                    final name = await _bloc.updateName(
                      isGroup: isGroup,
                      id: isGroup ? widget.groupProvider!.group.groupID : uid,
                      newName: updatedText,
                      oldName: profileName,
                    );
                    if (isGroup) {
                      if (name == 'Invalid name.') return;
                      widget.groupProvider!.setGroupName(name);
                    }
                  } else {
                    final desc = await _bloc.updateStatus(
                      isGroup: isGroup,
                      id: isGroup ? widget.groupProvider!.group.groupID : uid,
                      newDesc: updatedText,
                      oldDesc: aboutMe,
                    );
                    if (isGroup) {
                      if (desc == 'Invalid description.') return;
                      widget.groupProvider!.setGroupDescription(desc);
                    }
                  }
                }
              },
              editable: true,
              hintText: content == Constants.changeName ? profileName : aboutMe,
            );
          },
          child: const Icon(Icons.edit_rounded),
        );
      } else {
        return const SizedBox();
      }
    } else {
      if (widget.userModel != null && widget.userModel!.uId != uid) {
        return const SizedBox();
      }

      return InkWell(
        onTap: () {
          showAnimatedDialog(
            context: context,
            title: title,
            content: content,
            textAction: "Change",
            onActionTap: (value, updatedText) {
              if (value) {
                if (content == Constants.changeName) {
                  _bloc.updateName(
                    isGroup: isGroup,
                    id: isGroup ? widget.groupProvider!.group.groupID : uid,
                    newName: updatedText,
                    oldName: profileName,
                  );
                } else {
                  _bloc.updateStatus(
                    isGroup: isGroup,
                    id: isGroup ? widget.groupProvider!.group.groupID : uid,
                    newDesc: updatedText,
                    oldDesc: aboutMe,
                  );
                }
              }
            },
            editable: true,
            hintText: content == Constants.changeName ? profileName : aboutMe,
          );
        },
        child: const Icon(Icons.edit_rounded),
      );
    }
  }
}

//Show group status widget
class GroupStatusWidget extends StatelessWidget {
  const GroupStatusWidget({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupBloc groupProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: !isAdmin
              ? null
              : () {
            // show dialog to change group type
            showAnimatedDialog(
              context: context,
              title: 'Change Group Type',
              content:
              'Are you sure you want to change the group type to ${groupProvider.group.isPrivate ? 'Public' : 'Private'}?',
              textAction: 'Change',
              onActionTap: (value, _) {
                if (value) {
                  // change group type
                  groupProvider.changeGroupType();
                }
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.deepPurple : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              groupProvider.group.isPrivate ? 'Private' : 'Public',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _getRequestWidget(
            context: context, isAdmin: isAdmin, bloc: groupProvider),
      ],
    );
  }

  Widget _getRequestWidget({
    required BuildContext context,
    required bool isAdmin,
    required GroupBloc bloc,
  }) {
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
//Show profile status widget

class ProfileStatusWidget extends StatefulWidget {
  final UserModel userModel;
  final UserModel currentUser;

  const ProfileStatusWidget({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  @override
  State<ProfileStatusWidget> createState() => _ProfileStatusWidgetState();
}

class _ProfileStatusWidgetState extends State<ProfileStatusWidget> {
  ProfileBloc get _bloc => BlocProvider.of<ProfileBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is SendFriendRequestSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).requestSent,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is SendFriendRequestFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Send friend request failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is CancelFriendRequestSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).requestCanceled,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is CancelFriendRequestFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Cancel friend request failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is AcceptFriendRequestSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).friendRequestAccepted,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is AcceptFriendRequestFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Accept friend request failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is UnFriendSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).unFriend,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is UnFriendFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Unfriend failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        }
      },
      builder: (context, state) {
        return Row(
          children: [
            FriendsButton(
              currentUser: widget.currentUser,
              userModel: widget.userModel,
              bloc: _bloc,
            ),
            const SizedBox(height: 10),
            FriendRequestButton(
              currentUser: widget.currentUser,
              userModel: widget.userModel,
            ),
          ],
        );
      },
    );
  }
}

// friend request button
class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return _buildFriendRequestButton(context);
  }

  // friend request button
  Widget _buildFriendRequestButton(BuildContext context) {
    if (currentUser.uId == userModel.uId &&
        userModel.friendsRequestsUIds.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: IconButton(
            onPressed: () {
              // navigate to friend requests screen
              Navigator.pushNamed(context, Routes.friendRequestScreen);
            },
            icon: const Icon(
              Icons.person_add,
              color: Colors.black,
            ),
          ),
        ),
      );
      // return MyElevatedButton(
      //   onPressed: () {
      //     //TODO: navigate to friend requests screen
      //     Navigator.pushNamed(context, Routes.friendRequestScreen);
      //   },
      //   label: 'Requests',
      //   width: MediaQuery.of(context).size.width * 0.4,
      //   backgroundColor: Theme.of(context).cardColor,
      //   textColor: Theme.of(context).colorScheme.primary,
      // );
    } else {
      // not in our profile
      return const SizedBox.shrink();
    }
  }
}

// friends button
class FriendsButton extends StatelessWidget {
  final UserModel userModel;
  final UserModel currentUser;
  final ProfileBloc bloc;

  const FriendsButton({
    super.key,
    required this.userModel,
    required this.currentUser,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFriendsButton(context);
  }

  Widget _buildFriendsButton(context) {
    if (currentUser.uId == userModel.uId && userModel.friendsUIds.isNotEmpty) {
      return MyElevatedButton(
        onPressed: () {
          // navigate to friends screen
          Navigator.pushNamed(context, Routes.friendsScreen);
        },
        label: 'Friends',
        width: MediaQuery.of(context).size.width * 0.4,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      if (currentUser.uId != userModel.uId) {
        // show cancel friend request button if the user sent us friend request
        // else show send friend request button
        if (userModel.friendsRequestsUIds.contains(currentUser.uId)) {
          // show send friend request button
          return MyElevatedButton(
            onPressed: () async {
              //TODO: cancel friend request
              bloc.add(CancelFriendRequestEvent(userModel.uId));
            },
            label: 'Cancel Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).colorScheme.primary,
          );
        } else if (userModel.sendFriendRequestsUIds.contains(currentUser.uId)) {
          return MyElevatedButton(
            onPressed: () async {
              //TODO: accept friend request
              bloc.add(AcceptFriendRequestEvent(userModel.uId));
            },
            label: 'Accept Friend',
            width: MediaQuery.of(context).size.width * 0.4,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).colorScheme.primary,
          );
        } else if (userModel.friendsUIds.contains(currentUser.uId)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyElevatedButton(
                onPressed: () async {
                  //TODO: unfriend
                  //show dialog to confirm unfriend
                  _showLogOutDialog(context);
                },
                label: 'Unfriend',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor: Colors.deepPurple,
                textColor: Colors.white,
              ),
              const SizedBox(width: 10),
              MyElevatedButton(
                onPressed: () async {
                  // navigate to chat screen
                  // navigate to chat screen with the folowing arguments
                  // 1. friend uid 2. friend name 3. friend image 4. groupId with an empty string
                  //TODO: navigate to chat screen
                  Navigator.pushNamed(
                    context,
                    Routes.chatWithFriendScreen,
                    arguments: {
                      "friendId": userModel.uId,
                      "friendName": userModel.name,
                      "friendImage": userModel.image,
                      "groupId": ""
                    },
                  );
                },
                label: 'Chat',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          );
        } else {
          return MyElevatedButton(
            onPressed: () async {
              //TODO: send friend request
              bloc.add(SendFriendRequestEvent(userModel.uId));
            },
            label: 'Send Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).colorScheme.primary,
          );
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  void _showLogOutDialog(BuildContext context) {
    showActionDialogWidget(
      context: context,
      text: S.of(context).unFriend,
      iconData: CupertinoIcons.delete,
      primaryText: S.of(context).yes,
      secondaryText: S.of(context).no,
      primaryAction: () async {
        bloc.add(UnfriendEvent(userModel.uId));
        Navigator.pop(context);
      },
      secondaryAction: () {
        Navigator.pop(context);
      },
    );
  }
}

//my elevated button
class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.textColor,
  });

  final VoidCallback onPressed;
  final String label;
  final double width;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget buildElevatedButton() {
      return SizedBox(
        //width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return buildElevatedButton();
  }
}
