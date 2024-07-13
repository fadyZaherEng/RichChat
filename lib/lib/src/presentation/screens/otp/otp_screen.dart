import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  UserModel _user = UserModel();
  bool isArabic = false;
  String _uId = '';

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
                        });
                        _verifyCode(
                          verificationId: widget.verificationCode,
                          otpCode: _otpCode,
                          context: context,
                        );
                      },
                    ),
                    _bloc.isLoading
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                    _bloc.isSuccessful
                        ? Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        : const SizedBox.shrink(),
                    _bloc.secondsRemaing == 0
                        ? const SizedBox.shrink()
                        : Text(
                            "${_bloc.secondsRemaing} Seconds Remaining",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: ColorSchemes.black),
                          ),
                    _bloc.secondsRemaing == 0
                        ? const SizedBox.shrink()
                        : const SizedBox(height: 20),
                    _bloc.isLoading
                        ? const SizedBox.shrink()
                        : Text(
                            S.of(context).didReceiveTheCode,
                            style: GoogleFonts.openSans(fontSize: 16),
                          ),
                    const SizedBox(height: 10),
                    _bloc.isLoading
                        ? const SizedBox.shrink()
                        : TextButton(
                            onPressed: _bloc.secondsRemaing == 0
                                ? () {
                                    // reset the code to send again
                                    _bloc.resendCode(
                                      context: context,
                                      phone: widget.phoneNumber,
                                    );
                                  }
                                : null,
                            child: Text(
                              S.of(context).resendCode,
                              style: GoogleFonts.openSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _verifyCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
  }) async {
    _bloc.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: ({
        required String userId,
      }) async {
        _uId = userId;
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
      },
    );
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
