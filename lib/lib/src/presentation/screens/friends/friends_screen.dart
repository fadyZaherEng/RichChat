import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/friends/friends_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/friends_list_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/build_app_bar_widget.dart';

class FriendsScreen extends BaseStatefulWidget {
  const FriendsScreen({super.key});

  @override
  BaseState<FriendsScreen> baseCreateState() => _FriendsScreenState();
}

class _FriendsScreenState extends BaseState<FriendsScreen> {
  final _searchController = TextEditingController();

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<FriendsBloc, FriendsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: buildAppBarWidget(context,
              title: S.of(context).friends,
              isHaveBackButton: true, onBackButtonPressed: () {
            Navigator.pop(context);
          }),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
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
              const SizedBox(height: 15),
              const FriendsListWidget(
                friendViewType: FriendViewType.friend,
                groupId: '',
              ),
            ],
          ),
        );
      },
    );
  }
}
