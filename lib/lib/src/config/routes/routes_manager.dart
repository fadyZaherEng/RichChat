import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/chat_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/play_video_full_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/create_group/create_group_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/firends_requests/frients_requests_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/friends/friends_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/geoup_settings/group_settings_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/group_info_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/home/home_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/login/login_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/main/main_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/otp/otp_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/profile/profile_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/settings/settings_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/splash/splash_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/user_information/user_information_screen.dart';

class Routes {
  static const String splash = "/";
  static const String logInScreen = "/logInScreen";
  static const String homeScreen = "/homeScreen";
  static const String settingsScreen = "/settingsScreen";
  static const String mainScreen = "/mainScreen";
  static const String chatScreen = "/chatScreen";
  static const String otpScreen = "/otpScreen";
  static const String userInfoScreen = "/userInfoScreen";
  static const String profileScreen = "/profileScreen";
  static const String friendRequestScreen = "/friendRequestScreen";
  static const String friendsScreen = "/friendsScreen";
  static const String chatWithFriendScreen = "/chatWithFriendScreen";
  static const String fullVideoScreen = "/full_video_screen";
  static const String createGroupScreen = "/createGroupScreen";
  static const String settingsGroupScreen = "/settingsGroupScreen";
  static const String groupInformationScreen = "/groupInformationScreen";
}

class RoutesManager {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    print("routeSettings.name: ${routeSettings.name}");
    switch (routeSettings.name) {
      case Routes.splash:
        return _materialRoute(const SplashScreen());
      case Routes.userInfoScreen:
        Map<String, dynamic> arg =
            routeSettings.arguments as Map<String, dynamic>;
        return _materialRoute(UserInformationScreen(
          phoneNumber: arg["phoneNumber"],
          userId: arg["userId"], //userId
        ));
      case Routes.logInScreen:
        return _materialRoute(const LogInScreen());
      case Routes.homeScreen:
        return _materialRoute(const HomeScreen());
      case Routes.settingsScreen:
        return _materialRoute(const SettingsScreen());
      case Routes.mainScreen:
        return _materialRoute(const MainScreen());
      case Routes.otpScreen:
        Map<String, dynamic> arg =
            routeSettings.arguments as Map<String, dynamic>;
        return _materialRoute(OtpScreen(
          phoneNumber: arg["phoneNumber"],
          verificationCode: arg["verificationCode"],
        ));
      case Routes.profileScreen:
        Map<String, dynamic> arg =
            routeSettings.arguments as Map<String, dynamic>;
        return _materialRoute(ProfileScreen(
          userId: arg["userId"],
        ));
      case Routes.friendRequestScreen:
        Map<String, dynamic> arg =
            routeSettings.arguments as Map<String, dynamic>;
        return _materialRoute( FriendRequestsScreen(
          groupId: arg["groupId"],
        ));
      case Routes.friendsScreen:
        return _materialRoute(const FriendsScreen());
      case Routes.chatWithFriendScreen:
        Map<String, dynamic> arg =
            routeSettings.arguments as Map<String, dynamic>;
        return _materialRoute(ChatScreen(
          friendId: arg["friendId"],
          friendName: arg["friendName"],
          friendImage: arg["friendImage"],
          groupId: arg["groupId"],
        ));
       case Routes.fullVideoScreen:
        Map<String, dynamic> arg =
            routeSettings.arguments as Map<String, dynamic>;
        return _materialRoute(PlayVideoFullScreen(
          videoPath: arg["videoPath"],
        ));
        case Routes.createGroupScreen:
        return _materialRoute(const CreateGroupScreen());
        case Routes.settingsGroupScreen:
        return _materialRoute(const GroupSettingsScreen());
        case Routes.groupInformationScreen:
        return _materialRoute(const GroupInformationScreen());
      default:
        return _materialRoute(const SplashScreen());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }

  static Route<dynamic> unDefinedRoute(String name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Not found")),
        body: Center(
          child: Text(name),
        ),
      ),
    );
  }
}
