import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_animated_dialog.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/my_chats/widgets/my_chats_user_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';

class PublicGroupScreen extends BaseStatefulWidget {
  const PublicGroupScreen({super.key});

  @override
  BaseState<PublicGroupScreen> baseCreateState() => _PublicGroupScreenState();
}

class _PublicGroupScreenState extends BaseState<PublicGroupScreen> {
  GroupBloc get _bloc => BlocProvider.of<GroupBloc>(context);
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is SendRequestToJoinGroupSuccessState) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Request Sent",
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSearchTextField(
                    placeholder: S.of(context).search,
                    controller: _searchController,
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream: _bloc.getAllPublicGroupsStream(
                      userId: GetUserUseCase(injector())().uId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.data != null &&
                        snapshot.data!.isEmpty) {
                      return const Center(child: Text("No Public Group Found"));
                    }
                    return Expanded(
                      child: ListView.separated(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final groupModel = snapshot.data![index];
                          return LastMassageChatWidget(
                            group: groupModel,
                            isGroup: true,
                            onTap: () {
                              //TODO: navigate to chat screen
                              if (groupModel.membersUIDS
                                  .contains(GetUserUseCase(injector())().uId)) {
                                _bloc
                                    .setGroup(group: groupModel)
                                    .whenComplete(() {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.chatWithFriendScreen,
                                    arguments: {
                                      "friendId": groupModel.groupID,
                                      "friendName": groupModel.groupName,
                                      "friendImage": groupModel.groupLogo,
                                      "groupId": groupModel.groupID,
                                    },
                                  );
                                });
                                return;
                              }
                              if (groupModel.requestToJoin) {
                                //check if request already sent
                                if (groupModel.awaitingApprovalUIDS.contains(
                                    GetUserUseCase(injector())().uId)) {
                                  //show snack bar
                                  CustomSnackBarWidget.show(
                                    context: context,
                                    message: "Request Already Sent",
                                    path: ImagePaths.icSuccess,
                                    backgroundColor: ColorSchemes.green,
                                  );
                                  return;
                                }
                                //show dialog to send request to join group
                                showAnimatedDialog(
                                  context: context,
                                  textAction: "Request To Join",
                                  title: "Request To Join",
                                  content:
                                      "you need request to join this group,before you can chat with members of this group",
                                  onActionTap: (value) {
                                    //TODO: send request to join
                                    if (value) {
                                      _bloc.add(SendRequestToJoinGroupEvent(
                                        uid: GetUserUseCase(injector())().uId,
                                        groupName: groupModel.groupName,
                                        groupImage: groupModel.groupLogo,
                                        groupId: groupModel.groupID,
                                      ));
                                    }
                                  },
                                );
                                return;
                              }
                              _bloc
                                  .setGroup(group: groupModel)
                                  .whenComplete(() {
                                Navigator.pushNamed(
                                  context,
                                  Routes.chatWithFriendScreen,
                                  arguments: {
                                    "friendId": groupModel.groupID,
                                    "friendName": groupModel.groupName,
                                    "friendImage": groupModel.groupLogo,
                                    "groupId": groupModel.groupID,
                                  },
                                );
                              });
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
