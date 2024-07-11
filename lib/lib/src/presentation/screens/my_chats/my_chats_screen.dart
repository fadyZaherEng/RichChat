import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/di/injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/my_chats/widgets/my_last_massages_stream.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/search_stream_widget.dart';

class ChatsScreen extends BaseStatefulWidget {
  const ChatsScreen({super.key});

  @override
  BaseState<ChatsScreen> baseCreateState() => _ChatsScreenState();
}

class _ChatsScreenState extends BaseState<ChatsScreen> {
  ChatsBloc get _bloc => BlocProvider.of<ChatsBloc>(context);
  final _searchController = TextEditingController();
  UserModel currentUser = UserModel();

  @override
  void initState() {
    super.initState();
    _bloc.add(GetAllUsersEvent());
    currentUser = GetUserUseCase(injector())();
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state is GetUserChatsSuccess) {
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
                  child: _bloc.searchQuery.isEmpty
                      ? MyChatsStream(
                          myChatsStream: _bloc.getChatsLastMassagesStream(
                          userId: GetUserUseCase(injector())().uId,
                        ))
                      : SearchStreamWidget(uid: currentUser.uId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
