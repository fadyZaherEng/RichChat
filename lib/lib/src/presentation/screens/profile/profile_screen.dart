import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_action_dialog.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/profile/profile_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/build_app_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class ProfileScreen extends BaseStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  BaseState<ProfileScreen> baseCreateState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseState<ProfileScreen> {
  UserModel _currentUser = UserModel();
  UserModel _otherUser = UserModel();

  ProfileBloc get _bloc => BlocProvider.of<ProfileBloc>(context);

  @override
  void initState() {
    super.initState();
    _currentUser = GetUserUseCase(injector())();
  }

  @override
  Widget baseBuild(BuildContext context) {
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
        return Scaffold(
          appBar: buildAppBarWidget(
            backgroundColor: Theme.of(context).cardColor,
            context,
            title: S.of(context).profile,
            actionWidget: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.settingsScreen);
              },
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            isHaveBackButton: true,
            onBackButtonPressed: () {
              Navigator.pop(context);
            },
          ),
          body: StreamBuilder(
            stream: FirebaseSingleTon.db
                .collection(Constants.users)
                .doc(widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                _otherUser = UserModel.fromJson(snapshot.data!.data()!);
                return Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          //TODO: navigate to user profile screen
                        },
                        child: UserImageWidget(
                          width: 100,
                          height: 100,
                          image: _otherUser.image,
                          isBorder: false,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _otherUser.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      _currentUser.uId == _otherUser.uId
                          ? const SizedBox.shrink()
                          : Text(
                              _otherUser.phoneNumber,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDivider(),
                            const SizedBox(width: 10),
                            Text(
                              S.of(context).aboutMe,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 10),
                            _buildDivider(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _otherUser.aboutMe,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      _buildFriendRequestButton(
                          currentUser: _currentUser, otherUser: _otherUser),
                      const SizedBox(height: 10),
                      _buildFriendsStatusButton(
                          currentUser: _currentUser, otherUser: _otherUser),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel otherUser,
  }) {
    if (currentUser.uId == otherUser.uId) {
      if (otherUser.friendsRequestsUIds.isNotEmpty) {
        return _buildButton(
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: ColorSchemes.white,
            text: S.of(context).viewFriendRequests,
            onPressed: () {
              //TODO: navigate to friend requests screen
              Navigator.pushNamed(context, Routes.friendRequestScreen);
            });
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFriendsStatusButton({
    required UserModel currentUser,
    required UserModel otherUser,
  }) {
    if (currentUser.uId == otherUser.uId && otherUser.friendsUIds.isNotEmpty) {
      return _buildButton(
        width: MediaQuery.of(context).size.width * 0.6,
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: ColorSchemes.white,
        text: S.of(context).viewFriends,
        onPressed: () {
          //TODO: navigate to friends screen
          Navigator.pushNamed(context, Routes.friendsScreen);
        },
      );
    } else {
      if (currentUser.uId != otherUser.uId) {
        if (otherUser.friendsRequestsUIds.contains(_currentUser.uId)) {
          return _buildButton(
            width: MediaQuery.of(context).size.width * 0.6,
            textColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).cardColor,
            text: S.of(context).cancelFriendRequest,
            onPressed: () {
              //TODO: cancel friend request
              _bloc.add(CancelFriendRequestEvent(_otherUser.uId));
            },
          );
        } else if (otherUser.sendFriendRequestsUIds.contains(_currentUser.uId)) {
          return _buildButton(
            width: MediaQuery.of(context).size.width * 0.6,
            textColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).cardColor,
            text: S.of(context).acceptFriendRequest,
            onPressed: () {
              //TODO: accept friend request
              _bloc.add(AcceptFriendRequestEvent(otherUser.uId));
            },
          );
        } else if (otherUser.friendsUIds.contains(_currentUser.uId)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                width: MediaQuery.of(context).size.width * 0.4,
                textColor: ColorSchemes.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
                text: S.of(context).unFriend.toUpperCase(),
                onPressed: () {
                  //TODO: unfriend
                  //show dialog to confirm unfriend
                  _showLogOutDialog(context);
                },
              ),
              _buildButton(
                width: MediaQuery.of(context).size.width * 0.4,
                textColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).cardColor,
                text: S.of(context).chat.toUpperCase(),
                onPressed: () {
                  //TODO: navigate to chat screen
                  Navigator.pushNamed(
                    context,
                    Routes.chatWithFriendScreen,
                    arguments: {
                      "friendId": _otherUser.uId,
                      "friendName": _otherUser.name,
                      "friendImage": _otherUser.image,
                      "groupId": ""
                    },
                  );
                },
              ),
            ],
          );
        } else {
          return _buildButton(
            width: MediaQuery.of(context).size.width * 0.6,
            textColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            text: S.of(context).sendFriendRequests,
            onPressed: () {
              //TODO: send friend request
              _bloc.add(SendFriendRequestEvent(otherUser.uId));
            },
          );
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildButton({
    required String text,
    required Color textColor,
    required Color backgroundColor,
    required double width,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: backgroundColor,
          width: 0,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorSchemes.lightGray.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  _buildDivider() => const SizedBox(
        height: 40,
        width: 40,
        child: Divider(
          color: ColorSchemes.gray,
          thickness: 1,
        ),
      );

  void _showLogOutDialog(BuildContext context) {
    showActionDialogWidget(
        context: context,
        text: S.of(context).unFriend,
        iconData: CupertinoIcons.delete,
        primaryText: S.of(context).yes,
        secondaryText: S.of(context).no,
        primaryAction: () async {
          _bloc.add(UnfriendEvent(_otherUser.uId));
        },
        secondaryAction: () {
          Navigator.pop(context);
        });
  }
}
