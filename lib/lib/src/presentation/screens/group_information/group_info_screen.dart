import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/utils/show_add_member_bottom_sheet.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/add_members_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/exit_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/info_card_details_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/group_members_card_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/settings_and_media_widget.dart';

class GroupInformationScreen extends StatefulWidget {
  const GroupInformationScreen({super.key});

  @override
  State<GroupInformationScreen> createState() => _GroupInformationScreenState();
}

class _GroupInformationScreenState extends State<GroupInformationScreen> {
  GroupBloc get _bloc => BlocProvider.of<GroupBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {},
      builder: (context, state) {
        final uid = FirebaseSingleTon.auth.currentUser!.uid;
        //check if admin or not
        bool isAdmin = _bloc.group.adminsUIDS.contains(uid);
        //check if member or not
        bool isMember = _bloc.group.membersUIDS.contains(uid);
        return Scaffold(
          appBar: AppBar(
            title: const Text("Group Information"),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InfoCardDetailsWidget(
                    bloc: _bloc,
                    isAdmin: isAdmin,
                  ),
                  const SizedBox(height: 10),
                  SettingsAndMediaWidget(isAdmin: isAdmin, bloc: _bloc),
                  const SizedBox(height: 20),
                  AddMembers(
                    bloc: _bloc,
                    isAdmin: isAdmin,
                    onTap: () {
                      //show bottom sheet to add members
                      showAddMembersBottomSheet(
                        context: context,
                        groupMembersUIDs: _bloc.group.membersUIDS,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  isMember
                      ? Column(
                          children: [
                            GroupMembersCardWidget(
                                isAdmin: isAdmin, bloc: _bloc),
                            const SizedBox(height: 10),
                            ExitGroupCardWidget(
                              uid: uid,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
