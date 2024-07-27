import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/create_group/widgets/setting_list_tile_widget.dart';

class SettingsAndMediaWidget extends StatelessWidget {
  final bool isAdmin;
  final GroupBloc bloc;
  const SettingsAndMediaWidget({
    super.key,
    required this.isAdmin,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            SettingListTileWidget(
              title: "Media",
              icon: Icons.image,
              iconColor: Colors.deepPurple,
              onTap: () {
                //navigate to media screen
              },
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SettingListTileWidget(
              title: "Group Settings",
              icon: Icons.settings,
              iconColor: Colors.deepPurple,
              onTap: () {
                if(!isAdmin){
                  // Sho.show(context, "Only admin can edit group settings");
                }
                //navigate to group settings
                Navigator.pushNamed(context, Routes.settingsGroupScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
