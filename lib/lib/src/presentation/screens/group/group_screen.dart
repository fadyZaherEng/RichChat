import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group/privte_group/privte_group_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group/public_group/public_group_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_tap_bar_widget.dart';

class GroupScreen extends BaseStatefulWidget {
  const GroupScreen({super.key});

  @override
  BaseState<GroupScreen> baseCreateState() => _GroupScreenState();
}

class _GroupScreenState extends BaseState<GroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget baseBuild(BuildContext context) {
    return Scaffold(
      body:CustomTabBarWidget(
        titleOfTapOne: S.of(context).privateGroup,
        titleOfTapTwo: S.of(context).publicGroup,
        contentOfTapOne: const PrivateGroupScreen(),
        contentOfTapTwo: const PublicGroupScreen(),
        tabController: tabController,
      ),
    );
  }
}
