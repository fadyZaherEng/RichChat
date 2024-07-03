import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/create_group/widgets/setting_list_tile_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/geoup_settings/widgets/bottom_sheet_content_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/geoup_settings/widgets/settings_switch_list_tile_widget.dart';

class GroupSettingsScreen extends BaseStatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  BaseState<GroupSettingsScreen> baseCreateState() =>
      _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends BaseState<GroupSettingsScreen> {
  GroupBloc get groupProvider => BlocProvider.of<GroupBloc>(context);

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).groupSettings),
            centerTitle: true,
          ),
          body: Column(
            children: [
              SettingsSwitchListTileWidget(
                title: S.of(context).editGroupSettings,
                value: groupProvider.group.editSettings,
                subtitle: S.of(context).onlyAdminsCanEditGroupSettings,
                backgroundColor: Colors.green,
                icon: Icons.edit,
                onChanged: (value) {
                  groupProvider.setEditSettings(editSettings: value);
                },
              ),
              const SizedBox(height: 10),
              groupProvider.group.approveMembers
                  ? SettingsSwitchListTileWidget(
                      title: S.of(context).approveNewMembers,
                      value: groupProvider.group.approveMembers,
                      subtitle: S
                          .of(context)
                          .NewMembersWillBeApprovedOnlyAfterAdminApproval,
                      backgroundColor: Colors.blue,
                      icon: Icons.approval,
                      onChanged: (value) {
                        groupProvider.setApproveNewMembers(
                            approveNewMembers: value);
                      },
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              SettingsSwitchListTileWidget(
                title: S.of(context).requestToJoinGroup,
                value: groupProvider.group.requestToJoin,
                subtitle: S
                    .of(context)
                    .requestIncomingMembersToJoinTheGroupBeforeViewingTheGroup,
                backgroundColor: Colors.orange,
                icon: Icons.request_page,
                onChanged: (value) {
                  groupProvider.setRequestToJoin(requestToJoin: value);
                },
              ),
              const SizedBox(height: 10),
              SettingsSwitchListTileWidget(
                title: S.of(context).lockMassages,
                value: groupProvider.group.lockMassages,
                subtitle: S
                    .of(context)
                    .onlyAdminsCanSendMessagesOtherMembersCanNotSendMessages,
                backgroundColor: Colors.deepPurple,
                icon: Icons.lock,
                onChanged: (value) {
                  groupProvider.setLockMassages(lockMassages: value);
                },
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                color: _getGroupAdminColor(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SettingListTileWidget(
                    title: "Group Admind",
                    subtitle: _getGroupAdminNames(),
                    icon: Icons.admin_panel_settings,
                    iconColor: Colors.red,
                    onTap: () {
                      if (groupProvider.groupMembersList.isEmpty) {
                        return;
                      }
                      //show bottom sheet to select admin
                      _showSelectAdminBottomSheet(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGroupAdminNames() {
    //get uid
    final uid = FirebaseSingleTon.auth.currentUser!.uid;
    //check if there are group members
    if (groupProvider.groupMembersList.isEmpty) {
      return "To Assign Admin roles ,Please add at least one member to the group";
    } else {
      List<String> groupAdminNames = [];
      //get the list of group admins
      List<UserModel> groupAdminsList = groupProvider.groupMembersList;
      //get a list of names from the list of group admins
      List<String> groupAdminNamesList =
          groupAdminsList.map((e) => e.uId==uid?S.of(context).you:e.name).toList();
      //add the group admin names to the list
      groupAdminNames.addAll(groupAdminNamesList);
      //return the list of group admin names
      return groupAdminNames.length == 2
          ? groupAdminNames.join(" and ")
          : groupAdminNames.length > 2
              ? "${groupAdminNames.sublist(0, groupAdminNames.length - 1).join(", ")} and ${groupAdminNames.last}"
              : S.of(context).you;
    }
  }

  Color _getGroupAdminColor() {
    if (groupProvider.groupMembersList.isEmpty) {
      return Theme.of(context).disabledColor;
    }
    return Theme.of(context).cardColor;
  }

  void _showSelectAdminBottomSheet(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContentWidget(
          groupProvider: groupProvider,
        );
      },
    );
  }
}
