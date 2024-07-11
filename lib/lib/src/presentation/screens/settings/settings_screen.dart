import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_action_dialog.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_language_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/settings/settings_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/build_app_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_switch_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/restart_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends BaseStatefulWidget {
  const SettingsScreen({super.key});

  @override
  BaseState<SettingsScreen> baseCreateState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseState<SettingsScreen> {
  bool isDarkMode = false;
  bool isArabic = false;

  SettingsBloc get _bloc => BlocProvider.of<SettingsBloc>(context);

  void _getThemeMode() async {
    final savedTheme = await AdaptiveTheme.getThemeMode();
    if (savedTheme != null && savedTheme == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _getThemeMode();
    isArabic = GetLanguageUseCase(injector())() == Constants.ar;
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is ChangeThemeSuccess) {
          RestartWidget.restartApp(context);
        } else if (state is ChangeLanguageSuccess) {
          RestartWidget.restartApp(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: buildAppBarWidget(
            context,
            title: S.of(context).settings,
            isHaveBackButton: true,
            onBackButtonPressed: () {
              Navigator.pop(context);
            },
            actionWidget: InkWell(
              onTap: () {
                _showLogOutDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSwitchWidget(
                    value: isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        isDarkMode = value;
                      });
                      if (value) {
                        AdaptiveTheme.of(context).setDark();
                      } else {
                        AdaptiveTheme.of(context).setLight();
                      }
                      RestartWidget.restartApp(context);
                    },
                    title: S.of(context).theme,
                  ),
                  const Divider(color: ColorSchemes.moreDivider),
                  CustomSwitchWidget(
                    value: isArabic,
                    onChanged: (bool value) {
                      _bloc.add(ChangeLanguageEvent(
                        language: value ? Constants.ar : Constants.en,
                      ));
                      setState(() {
                        isArabic = value;
                      });
                    },
                    title: S.of(context).language,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showActionDialogWidget(
      context: context,
      text: S.of(context).logOut,
      iconData: Icons.logout,
      primaryText: S.of(context).yes,
      secondaryText: S.of(context).no,
      primaryAction: () async {
        //log out
        Navigator.pop(context);
        await FirebaseSingleTon.auth.signOut();
        Navigator.pushReplacementNamed(context, Routes.logInScreen);
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      },
      secondaryAction: () {
        Navigator.pop(context);
      },
    );
  }
}
