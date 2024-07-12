import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_language_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/login/log_in_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/otp/widgets/otp_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';

class OtpScreen extends BaseStatefulWidget {
  final String phoneNumber;
  final String verificationCode;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationCode,
  });

  @override
  BaseState<OtpScreen> baseCreateState() => _OtpScreenState();
}

class _OtpScreenState extends BaseState<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _otpCode = '';
  String _uId = '';
  UserModel _user = UserModel();
  bool isArabic = false;
  bool _isLoading = false;

  LogInBloc get _bloc => BlocProvider.of<LogInBloc>(context);

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    isArabic = GetLanguageUseCase(injector())() == Constants.ar;
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<LogInBloc, LogInState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.03),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      S.of(context).verification,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 30, color: ColorSchemes.black),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      S.of(context).enterThe6Digit,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: ColorSchemes.black),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      isArabic
                          ? "${S.of(context).sentTo} \u200E${widget.phoneNumber}"
                          : "${S.of(context).sentTo} \u200F${widget.phoneNumber}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: ColorSchemes.black),
                    ),
                    const SizedBox(height: 30),
                    OtpWidget(
                      length: 6,
                      textEditingController: _otpController,
                      onCompleted: (pin) {
                        setState(() {
                          _otpCode = pin;
                          _isLoading = true;
                        });
                        _verifyCode(context);
                      },
                    ),
                    const SizedBox(height: 30),
                    Visibility(
                      visible: _isLoading,
                      child: Container(
                        height: 30,
                        width: 30,
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Visibility(
                        visible: !_isLoading,
                        child: Column(
                          children: [
                            Text(
                              S.of(context).didReceiveTheCode,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: ColorSchemes.black),
                            ),
                            const SizedBox(height: 15),
                            InkWell(
                              onTap: () {
                                //to do resend code
                                _bloc.add(
                                  LogInOnLogInEvent(
                                    widget.phoneNumber,
                                    context,
                                  ),
                                );
                              },
                              child: Text(
                                S.of(context).resendCode,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _verifyCode(BuildContext context) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationCode,
      smsCode: _otpCode,
    );
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      _uId = value.user!.uid;
      //check if user exists in firestore
      if (await _checkUserExists()) {
        // get user info
        await _getUserInfo();
        //save user info
        await _saveUserInfoInSharedPreferences(_user);
        //navigate to home
        Navigator.pushReplacementNamed(context, Routes.mainScreen);
      } else {
        //if user not exists navigate to user info
        Navigator.pushNamed(
          context,
          Routes.userInfoScreen,
          arguments: {
            "phoneNumber": widget.phoneNumber,
            "userId": _uId,
          },
        );
      }
      setState(() {
        _isLoading = false;
      });
    }).catchError((onError) {
      CustomSnackBarWidget.show(
          context: context,
          message: S.of(context).OTPSMSNotValid,
          path: ImagePaths.icCancel,
          backgroundColor: ColorSchemes.red);
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  Future<bool> _checkUserExists() async {
    final snapshot = await db.collection(Constants.users).doc(_uId).get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future _getUserInfo() async {
    final snapshot = await db.collection(Constants.users).doc(_uId).get();
    _user = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  Future _saveUserInfoInSharedPreferences(UserModel user) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (!prefs.containsKey(Constants.user)) {
    SetUserUseCase(injector())(user);
    // prefs.setString(Constants.user, jsonEncode(user.toJson()));
    // } else {
    //   // _user = UserModel.fromJson(jsonDecode(prefs.getString(Constants.user)!));
    //   _user=GetUserUseCase(injector())();
    // }
  }
}
