import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';

class GroupMemberWidget extends StatelessWidget {
  final List<String> membersUIDS;

  const GroupMemberWidget({
    super.key,
    required this.membersUIDS,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context
          .read<GroupBloc>()
          .streamGroupMembersData(membersUIDS: membersUIDS),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: SizedBox());
        // } else if (snapshot.hasError) {
        //   return const Center(child: Text("Something went wrong"));
        // }
        if (snapshot.hasData) {
          final members = snapshot.data;
          //get list of members names
          List<String> memberNames = [];
          for (var element in members!) {
            memberNames.add(element["name"] == GetUserUseCase(injector())().name
                ? "You"
                : element["name"]);
          }
          return Text(
            memberNames.length == 2
                ? memberNames.join(" and ")
                : memberNames.length > 2
                    ? "${memberNames.sublist(0, memberNames.length - 1).join(", ")} and ${memberNames.last}"
                    : memberNames.first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
