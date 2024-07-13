import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';

part 'log_in_event.dart';

part 'log_in_state.dart';

class LogInBloc extends Bloc<LogInEvent, LogInState> {
  bool _isLoading = false;
  bool _isSuccessful = false;
  int? _resendToken;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  Timer? _timer;
  int _secondsRemaing = 60;

  bool get isLoading => _isLoading;

  bool get isSuccessful => _isSuccessful;

  int? get resendToken => _resendToken;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;

  UserModel? get userModel => _userModel;

  int get secondsRemaing => _secondsRemaing;

  LogInBloc() : super(LogInInitial()) {
    on<LogInOnChangePhoneNumberEvent>(_onLogInOnChangePhoneNumberEvent);
    on<LogInOnChangeCountryEvent>(_onLogInOnChangeCountryEvent);
    on<LogInOnLogInEvent>(_onLogInOnLogInEvent);
  }

  FutureOr<void> _onLogInOnChangePhoneNumberEvent(
      LogInOnChangePhoneNumberEvent event, Emitter<LogInState> emit) {
    emit(LogInOnChangePhoneNumberState(event.value));
  }

  FutureOr<void> _onLogInOnLogInEvent(
      LogInOnLogInEvent event, Emitter<LogInState> emit) async {
    _isLoading = true;
    emit(LogInLoadingState());
    await FirebaseSingleTon.auth.verifyPhoneNumber(
      phoneNumber: event.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseSingleTon.auth
            .signInWithCredential(credential)
            .then((value) {
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          emit(LogInSuccessState(
              uId: FirebaseSingleTon.auth.currentUser!.uid, MSG: "success"));
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        _isSuccessful = false;
        _isLoading = false;
        emit(LogInErrorState(message: e.toString()));
        CustomSnackBarWidget.show(
          context: event.context,
          message: e.message.toString(),
          path: ImagePaths.icCancel,
          backgroundColor: ColorSchemes.red,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _isLoading = false;
        _resendToken = resendToken;
        _secondsRemaing = 60;
        _startTimer();
        emit(LogInCodeSentState(verificationId: verificationId));
        // navigate to otp screen
        Navigator.pushNamed(
          event.context,
          Routes.otpScreen,
          arguments: {
            "verificationCode": verificationId,
            "phoneNumber": event.phoneNumber,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
    );
    await Future.delayed(const Duration(seconds: 3));
    emit(LogInFinishState());
  }

  void _startTimer() {
    // cancel timer if any exist
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_secondsRemaing > 0) {
          _secondsRemaing--;
          emit(LogInTimerState(time: _secondsRemaing));
        } else {
          // cancel timer
          _timer?.cancel();
          emit(LogInTimerState(time: _secondsRemaing));
        }
      },
    );
  }

  // dispose timer
  @override
  void dispose() {
    _timer?.cancel();
  }

  // // resend code
  Future<void> resendCode({
    required BuildContext context,
    required String phone,
  }) async {
    if (_secondsRemaing == 0 || _resendToken != null) {
      // allow user to resend code only if timer is not running and resend token exists
      _isLoading = true;
      emit(LogInResentCodeSentLoadingState());
      await FirebaseSingleTon.auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseSingleTon.auth
              .signInWithCredential(credential)
              .then((value) async {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isSuccessful = true;
            _isLoading = false;
            emit(LogInResentCodeSentSuccessState());
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          emit(LogInResentCodeSentErrorState(message: e.toString()));
          CustomSnackBarWidget.show(
            context: context,
            message: e.message.toString(),
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          _isLoading = false;
          _resendToken = resendToken;
          emit(LogInResentCodeSentSuccessState());
          //show snack bar
          CustomSnackBarWidget.show(
            context: context,
            message: "Code sent successfully",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
      );
    } else {
      CustomSnackBarWidget.show(
        context: context,
        message: 'Please wait $_secondsRemaing seconds to resend',
        path: ImagePaths.icCancel,
        backgroundColor: ColorSchemes.red,
      );
    }
  }

  // verify otp code
  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function({
      required String userId,
    }) onSuccess,
  }) async {
    _isLoading = true;
    emit(LogInVerifyCodeLoadingState());
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    await FirebaseSingleTon.auth
        .signInWithCredential(credential)
        .then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess(userId: value.user!.uid);
      emit(LogInVerifyCodeSuccessState());
    }).catchError(
      (e) {
        _isSuccessful = false;
        _isLoading = false;
        emit(LogInVerifyCodeErrorState(message: e.toString()));
        CustomSnackBarWidget.show(
          context: context,
          message: e.message.toString(),
          path: ImagePaths.icCancel,
          backgroundColor: ColorSchemes.red,
        );
      },
    );
  }

  FutureOr<void> _onLogInOnChangeCountryEvent(
      LogInOnChangeCountryEvent event, Emitter<LogInState> emit) {
    emit(LogInOnChangeCountryState(event.country));
  }
}
