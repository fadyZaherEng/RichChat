import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/login/log_in_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/login/widgets/logo_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/login/widgets/phone_number_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';

class LogInScreen extends BaseStatefulWidget {
  const LogInScreen({super.key});

  @override
  BaseState<LogInScreen> baseCreateState() => _LogInScreenState();
}

class _LogInScreenState extends BaseState<LogInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  Country _selectedCountry = Country(
    phoneCode: "20",
    countryCode: "EG",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Egypt",
    example: "Egypt",
    displayName: "Egypt",
    displayNameNoCountryCode: "Egypt",
    e164Key: "+20",
  );

  LogInBloc get _bloc => BlocProvider.of<LogInBloc>(context);
  String _uId = '';

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<LogInBloc, LogInState>(
      listener: (context, state) {
        if (state is LogInOnChangePhoneNumberState) {
          _phoneController.text = state.value;
        } else if (state is LogInOnChangeCountryState) {
          _selectedCountry = state.country;
        } else if (state is LogInSuccessState) {
          _uId = state.uId;
          CustomSnackBarWidget.show(
            context: context,
            message: state.MSG,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is LogInErrorState) {
          CustomSnackBarWidget.show(
            context: context,
            message: state.message,
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is LogInLoadingState) {
          // showLoading();
        } else if (state is LogInFinishState) {
          // hideLoading();
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const LogoWidget(),
                  const SizedBox(height: 20),
                  Text(S.of(context).richChat,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ColorSchemes.black,
                            fontWeight: Constants.fontWeightBold,
                            fontSize: 23,
                          )),
                  const SizedBox(height: 5),
                  Text(S.of(context).addYourPhoneNumberMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ColorSchemes.black,
                            fontWeight: Constants.fontWeightSemiBold,
                          )),
                  const SizedBox(height: 20),
                  PhoneNumberWidget(
                    textEditingController: _phoneController,
                    isLoading: state is LogInLoadingState,
                    onChange: (value) =>
                        _bloc.add(LogInOnChangePhoneNumberEvent(value)),
                    onChangedCountry: (selectedCountry) =>
                        _bloc.add(LogInOnChangeCountryEvent(selectedCountry)),
                    selectedCountry: _selectedCountry,
                    sendOtpVerificationCode: () {
                      _bloc.add(
                        LogInOnLogInEvent(
                          "+${_selectedCountry.phoneCode}${_phoneController.text}",
                          context,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
