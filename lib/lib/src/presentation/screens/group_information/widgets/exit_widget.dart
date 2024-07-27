import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_animated_dialog.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/create_group/widgets/setting_list_tile_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';

class ExitGroupCardWidget extends StatelessWidget {
  const ExitGroupCardWidget({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SettingListTileWidget(
          title: 'Exit Group',
          icon: Icons.exit_to_app,
          iconColor: Colors.red,
          onTap: () {
            // exit group
            showAnimatedDialog(
              context: context,
              title: 'Exit Group',
              content: 'Are you sure you want to exit the group?',
              textAction: 'Exit',
              onActionTap: (value,_) async {
                if (value) {
                  // exit group
                  final groupProvider = context.read<GroupBloc>();
                  await groupProvider.exitGroup(uid: uid).whenComplete(() {
                    CustomSnackBarWidget.show(
                      context: context,
                      message: 'You have exited the group',
                      path: ImagePaths.icSuccess,
                      backgroundColor: Colors.green,
                    );
                    // navigate to first screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}
