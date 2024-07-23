import 'dart:developer';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/di/injector.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/friends/friends_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/login/log_in_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/main/main_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/profile/profile_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/settings/settings_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/user_info/user_info_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/restart_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,

  log("Handling a background message: ${message.messageId}");
  log("Handling a background message: ${message.notification!.title}");
  log("Handling a background message: ${message.notification!.body}");
  log("Handling a background message: ${message.data}");
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void>  main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final savedTheme = await AdaptiveTheme.getThemeMode();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(RestartWidget(MyApp(theme: savedTheme)));
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => const RestartWidget(MyApp()),
  //   ),
  // );
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  AdaptiveThemeMode? theme;

  MyApp({
    super.key,
    required this.theme,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainCubit>(create: (context) => injector()),
        BlocProvider<SettingsBloc>(create: (context) => injector()),
        BlocProvider<LogInBloc>(create: (context) => injector()),
        BlocProvider<UserInfoBloc>(create: (context) => injector()),
        BlocProvider<ChatsBloc>(create: (context) => injector()),
        BlocProvider<ProfileBloc>(create: (context) => injector()),
        BlocProvider<FriendsBloc>(create: (context) => injector()),
        BlocProvider<GroupBloc>(create: (context) => injector()),
      ],
      child: BlocBuilder<MainCubit, Locale>(
        buildWhen: (previousState, currentState) {
          return previousState != currentState;
        },
        builder: (context, state) {
          return AdaptiveTheme(
            light: ThemeData(
              useMaterial3: false,
              brightness: Brightness.light,
              colorSchemeSeed: Colors.deepPurple,
            ),
            dark: ThemeData(
              useMaterial3: false,
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.deepPurple,
            ),
            initial: widget.theme ?? AdaptiveThemeMode.light,
            builder: (lightTheme, darkTheme) => MaterialApp(
              // useInheritedMediaQuery: true,
              // builder: DevicePreview.appBuilder,
              theme: lightTheme,
              darkTheme: darkTheme,
              navigatorKey: navigatorKey,
              navigatorObservers: [
                ChuckerFlutter.navigatorObserver,
                routeObserver,
              ],
              themeMode: ThemeMode.light,
              supportedLocales: S.delegate.supportedLocales,
              onGenerateRoute: RoutesManager.getRoute,
              initialRoute: Routes.splash,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              locale: state,
              // home: FriendsScreen(),
            ),
          );
        },
      ),
    );
  }
}
