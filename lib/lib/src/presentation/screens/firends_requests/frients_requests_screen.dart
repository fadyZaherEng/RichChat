import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/friends_list_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/build_app_bar_widget.dart';

class FriendRequestsScreen extends BaseStatefulWidget {
  final String groupId;

  const FriendRequestsScreen({
    super.key,
    required this.groupId,
  });

  @override
  BaseState<FriendRequestsScreen> baseCreateState() =>
      _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends BaseState<FriendRequestsScreen> {
  final _searchController = TextEditingController();

  @override
  Widget baseBuild(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWidget(context,
          title: S.of(context).friendsRequests,
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
          const SizedBox(
            height: 15,
          ),
          FriendsListWidget(
            friendViewType: FriendViewType.friendRequest,
            groupId: widget.groupId,
          ),
        ],
      ),
    );
  }
}
