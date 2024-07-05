import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/last_massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/cricle_loading_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/my_chats/widgets/my_chats_user_widget.dart';

class ChatsScreen extends BaseStatefulWidget {
  const ChatsScreen({super.key});

  @override
  BaseState<ChatsScreen> baseCreateState() => _ChatsScreenState();
}

class _ChatsScreenState extends BaseState<ChatsScreen> {
  // List<UserModel> _users = [];

  ChatsBloc get _bloc => BlocProvider.of<ChatsBloc>(context);
  final _searchController = TextEditingController();
  UserModel _currentUser = UserModel();

  @override
  void initState() {
    super.initState();
    _bloc.add(GetAllUsersEvent());
    _currentUser = GetUserUseCase(injector())();
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state is GetUserChatsSuccess) {
          // _users = state.users;
        } else if (state is GetUserChatsError) {}
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: CupertinoSearchTextField(
                  placeholder: S.of(context).search,
                  prefixIcon: const Icon(CupertinoIcons.search),
                  onTap: () {},
                  onChanged: (value) {
                    _searchController.text = value;
                    setState(() {});
                    //filter stream based on search
                  },
                  controller: _searchController,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<LastMassage>>(
                  stream: _bloc.getChatsLastMassagesStream(
                      userId: GetUserUseCase(injector())().uId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleLoadingWidget();
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          S.of(context).somethingWentWrong,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorSchemes.gray,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.isEmpty ||
                        snapshot.data == null) {
                      return Center(
                        child: Text(
                          S.of(context).noFoundChatsUntilNow,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: ColorSchemes.black,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: ListView.separated(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final chats = snapshot.data![index];
                            return LastMassageChatWidget(
                              chats: chats,
                              isGroup: false,
                              onTap: () {
                                //TODO: navigate to chat screen
                                Navigator.pushNamed(
                                  context,
                                  Routes.chatWithFriendScreen,
                                  arguments: {
                                    "friendId": chats.receiverId,
                                    "friendName": chats.receiverName,
                                    "friendImage": chats.receiverImage,
                                    "groupId": ""
                                  },
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text("No Chats Found"),
                      );
                    }
                  },
                ),
              ),
            ],
          )),
        );
      },
    );
  }
}
