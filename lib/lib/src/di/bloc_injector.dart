import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/friends/friends_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/login/log_in_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/main/main_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/profile/profile_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/settings/settings_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/user_info/user_info_bloc.dart';

Future<void> initializeBlocDependencies() async {
  injector.registerFactory<MainCubit>(() => MainCubit(
        injector(),
        injector(),
      ));
  injector.registerFactory<SettingsBloc>(() => SettingsBloc(
        injector(),
        injector(),
      ));
  injector.registerFactory<LogInBloc>(() => LogInBloc());
  injector.registerFactory<UserInfoBloc>(() => UserInfoBloc(
        injector(),
      ));
  injector.registerFactory<ChatsBloc>(() => ChatsBloc());
  injector.registerFactory<ProfileBloc>(() => ProfileBloc());
  injector.registerFactory<FriendsBloc>(() => FriendsBloc());
  injector.registerFactory<GroupBloc>(() => GroupBloc());
}
