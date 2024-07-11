import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/last_massage_chat_widget.dart';

class PrivateGroupScreen extends BaseStatefulWidget {
  const PrivateGroupScreen({super.key});

  @override
  BaseState<PrivateGroupScreen> baseCreateState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends BaseState<PrivateGroupScreen> {
  final _searchController = TextEditingController();
  UserModel _currentUser = UserModel();

  GroupBloc get _bloc => BlocProvider.of<GroupBloc>(context);

  @override
  void initState() {
    super.initState();
    _currentUser = GetUserUseCase(injector())();
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {},
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
                  stream: _bloc.getAllPrivateGroupsStream(
                      userId: GetUserUseCase(injector())().uId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.data != null &&
                        snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No Private Group Found"));
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
                              _bloc.setGroup(group: groupModel).whenComplete(() {
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
