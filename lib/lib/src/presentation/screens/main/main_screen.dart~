import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/navigation_controller.dart';
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
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/notification_services.dart';

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
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    requestNotificationPermissions();
    NotificationServices.createNotificationChannelAndInitialize();
    initCloudMessaging();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _user = GetUserUseCase(injector())();
  }

  bool _appBadgeSupported = false;

  void initPlatformState() async {
    bool appBadgeSupported = false;
    try {
      bool res =false;// await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = true;
      } else {
        appBadgeSupported = false;
      }
    } on PlatformException {
      log('Failed');
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _appBadgeSupported = appBadgeSupported;
    });
    // remove app badge if supported
    if (_appBadgeSupported) {
      // FlutterAppBadger.removeBadge();
    }
  }

  // request notification permissions
  void requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
    }
    NotificationSettings notificationSettings =
    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // initialize cloud messaging
  void initCloudMessaging() async {
    // make sure widget is initialized before initializing cloud messaging
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. generate a new token
      await generateNewToken();
      // 2. initialize firebase messaging
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          // update app badge
          if (_appBadgeSupported) {
            // FlutterAppBadger.updateBadgeCount(1);
          }
          NotificationServices.displayNotification(message);
        }
      });
      // 3. setup onMessage handler
      setupInteractedMessage();
    });
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
                      }),
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


  // generate a new token
  Future<void> generateNewToken() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    log('Token: $token');
    // save token to firestore
    FirebaseSingleTon.db
        .collection("users")
        .doc(FirebaseSingleTon.auth.currentUser!.uid)
        .update({
      "token": token,
    });
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    navigationController(context: context, message: message);
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
           // FlutterAppBadger.removeBadge();
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
