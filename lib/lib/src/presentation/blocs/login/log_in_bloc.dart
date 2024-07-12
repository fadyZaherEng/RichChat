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
  // FirebaseAuth firebaseAuth =
  // FirebaseStorage storage = FirebaseStorage.instance;
  // FirebaseFirestore fireStore = FirebaseFirestore.instance;

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
    emit(LogInLoadingState());
    await FirebaseSingleTon.auth.verifyPhoneNumber(
      phoneNumber: event.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseSingleTon.auth.signInWithCredential(credential);
        emit(
          LogInSuccessState(
            uId: FirebaseSingleTon.auth.currentUser!.uid,
            MSG: "success",
          ),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        CustomSnackBarWidget.show(
          context: event.context,
          message: e.message.toString(),
          path: ImagePaths.icCancel,
          backgroundColor: ColorSchemes.red,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
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
    );
    await Future.delayed(const Duration(seconds: 3));
    emit(LogInFinishState());
  }

  // verify otp code
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;

  bool get isSuccessful => _isSuccessful;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;

  UserModel? get userModel => _userModel;

  // verify otp code
  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    emit(LogInLoadingState());
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
      onSuccess();
      emit(LogInSuccessState(uId: _uid!, MSG: "success"));
    }).catchError((e) {
      _isSuccessful = false;
      _isLoading = false;
      CustomSnackBarWidget.show(
        context: context,
        message: e.message.toString(),
        path: ImagePaths.icCancel,
        backgroundColor: ColorSchemes.red,
      );
    });
  }

//////////////////////////////////////////

  FutureOr<void> _onLogInOnChangeCountryEvent(
      LogInOnChangeCountryEvent event, Emitter<LogInState> emit) {
    emit(LogInOnChangeCountryState(event.country));
  }
}
