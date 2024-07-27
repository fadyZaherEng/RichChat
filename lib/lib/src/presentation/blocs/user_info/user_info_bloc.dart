import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_user_use_case.dart';

part 'user_info_event.dart';

part 'user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final SetUserUseCase setUserUseCase;
  UserInfoBloc(
    this.setUserUseCase,
      ) : super(UserInfoInitial()) {
    on<SelectImageEvent>(_onSelectImageEvent);
    on<ShowImageEvent>(_onShowImageEvent);
    on<ContinueEvent>(_onContinueEvent);
  }

  // FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  // FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  FutureOr<void> _onSelectImageEvent(
      SelectImageEvent event, Emitter<UserInfoState> emit) async {
    emit(SelectImageState(image: event.image));
  }

  FutureOr<void> _onShowImageEvent(
      ShowImageEvent event, Emitter<UserInfoState> emit) {
    emit(ShowImageState(image: event.image));
  }

  FutureOr<void> _onContinueEvent(
      ContinueEvent event, Emitter<UserInfoState> emit) async {
    emit(LoadingState());
    String imageUrl = "";
    if (event.image != null) {
      imageUrl = await _saveImageToStorage(
          event.image!, "UserImages/${FirebaseAuth.instance.currentUser!.uid}.jpg");
    }
    event.userModel=event.userModel.copyWith(image: imageUrl);
    await setUserUseCase(event.userModel);
    try {
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.userModel.uId)
          .set(event.userModel.toJson());
      emit(SuccessState());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }

  Future<String> _saveImageToStorage(File file, reference) async {
    Reference ref = FirebaseSingleTon.storage.ref(reference);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
