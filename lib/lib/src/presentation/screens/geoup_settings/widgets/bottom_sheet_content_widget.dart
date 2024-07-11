import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/friend_widget.dart';

class BottomSheetContentWidget extends StatelessWidget {
  final GroupBloc groupProvider;

  const BottomSheetContentWidget({
    super.key,
    required this.groupProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTitleWidget(context),
            const SizedBox(height: 15),
            Expanded(
                child: ListView.builder(
                    itemCount: groupProvider.groupMembersList.length,
                    itemBuilder: (context, index) {
                      final friend = groupProvider.groupMembersList[index];
                      return FriendWidget(
                        friend: friend,
                        friendViewType: FriendViewType.groupView,
                        isAdminView: true,
                        groupId: groupProvider.group.groupID,
                      );
                    })),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          S.of(context).selectGroupAdmin,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        const Spacer(),
        Expanded(
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Text(
              S.of(context).done,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
