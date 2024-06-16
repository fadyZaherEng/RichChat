import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/home/home_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/login/login_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/main/main_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/otp/otp_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/settings/settings_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/splash/splash_screen.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/user_information/user_information_screen.dart';

class Routes {
  static const String splash = "/";
  static const String landing = "/landing";
  static const String logInScreen = "/logInScreen";
  static const String homeScreen = "/homeScreen";
  static const String settingsScreen = "/settingsScreen";
  static const String mainScreen = "/mainScreen";
  static const String chatScreen = "/chatScreen";
  static const String otpScreen = "/otpScreen";
  static const String userInfoScreen = "/userInfoScreen";

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
        return _materialRoute( UserInformationScreen(
          phoneNumber: arg["phoneNumber"],
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
