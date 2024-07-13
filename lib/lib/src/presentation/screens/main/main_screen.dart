import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group/group_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/my_chats/my_chats_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/people/globe_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class MainScreen extends BaseStatefulWidget {
  const MainScreen({super.key});

  @override
  BaseState<MainScreen> baseCreateState() => _MainScreenState();
}

class _MainScreenState extends BaseState<MainScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  final List<Widget> _screens = [
    const ChatsScreen(),
    const GroupScreen(),
    const GlobeScreen(),
  ];
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  UserModel _user = UserModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _user = GetUserUseCase(injector())();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {});
  }

  @override
  Widget baseBuild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          S.of(context).appTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      _user.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    //navigate to user profile
                    Navigator.pushNamed(
                      context,
                      Routes.profileScreen,
                      arguments: {
                        "userId": _user.uId,
                      },
                    );
                  },
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseSingleTon.db
                        .collection("users")
                        .doc(_user.uId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      //get user image
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      String image = snapshot.data!["image"];
                      return UserImageWidget(image: image);
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chat_bubble_2_fill),
            label: S.of(context).chats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.group),
            label: S.of(context).groups,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.globe),
            label: S.of(context).globes,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                context.read<GroupBloc>().clearGroupData().whenComplete(() {
                  Navigator.pushNamed(context, Routes.createGroupScreen);
                });
              },
              child: const Icon(CupertinoIcons.add),
            )
          : null,
    );
  }

  //TODO: implement updateUserOnlineStatus
  Future<void> updateUserOnlineStatus({
    required bool isOnline,
  }) async {
    await FirebaseSingleTon.db
        .collection(Constants.users)
        .doc(FirebaseSingleTon.auth.currentUser!.uid)
        .update({"isOnline": isOnline});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        updateUserOnlineStatus(isOnline: true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        updateUserOnlineStatus(isOnline: false);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }
}
