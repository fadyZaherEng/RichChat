// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:city_eye/flavors.dart';
import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/core/utils/constants.dart';
import 'package:city_eye/src/core/utils/massage_type.dart';
import 'package:city_eye/src/core/utils/save_image_to_storage.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/domain/entities/chat/massage_reply.dart';
import 'package:city_eye/src/domain/entities/sign_in/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'chats_event.dart';

part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsInitial()) {
    on<SendTextMessageEvent>(_onSendTextMessageEvent);
    on<SelectReactionEvent>(_onSelectReactionEven);
    on<DeleteMassageEvent>(_onDeleteMassageEvent);
    on<SendFileMessageEvent>(_onSendFileMessageEvent);
    on<SelectImageEvent>(_onSelectImageEvent);
    on<SelectVideoFromGalleryEvent>(_onSelectVideoFromGalleryEvent);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //replay message
  MassageReply? _massageReply;

  MassageReply? get massageReply => _massageReply;

  void setMassageReply(MassageReply? massageReply) {
    _massageReply = massageReply;
    emit(SetMassageReplyState(massageReply: massageReply));
  }

  FutureOr<void> _onSendTextMessageEvent(
      SendTextMessageEvent event, Emitter<ChatsState> emit) async {
    emit(SendTextMessageLoading());
    //generate id to massage
    var massageId = const Uuid().v4();
    //check if massage is reply then add replied message to massage
    String repliedMessage = _massageReply?.massage ?? "";
    String repliedTo = _massageReply == null
        ? ""
        : _massageReply!.isMe
            ? S.current.you
            : _massageReply!.senderName;
    MassageType repliedMessageType =
        _massageReply?.massageType ?? MassageType.text;
    //update massage model with replied message
    final massage = Massage(
      senderId: event.sender.userInformation.id,
      senderName: event.sender.userInformation.name,
      senderImage: event.sender.userInformation.image,
      receiverId: event.receiverId,
      massage: event.message,
      massageType: event.massageType,
      timeSent: DateTime.now(),
      messageId: massageId,
      isSeen: false,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
      reactions: [],
      isSeenBy: [event.sender.userInformation.id],
      isDeletedBy: [],
    );
    //handle group massage
    await _firestore
        .collection("${Constants.company}${F.appCode}")
        .doc("${Constants.subscriberId}${event.subscriberId}")
        .collection(Constants.chats)
        .doc("${Constants.compoundId}${event.compoundId}")
        .collection(Constants.messages)
        .doc(massageId)
        .set(massage.toJson())
        .then((value) {
      //set massage reply to null
      setMassageReply(null);
      emit(SendTextMessageSuccess());
    }).catchError((error) {
      emit(SendTextMessageError(message: error.toString()));
      print("ErorrrrrrrrrrrrrrrrrrrrSendTextMessage$error");
    });
  }

  //get massages stream
  Stream<List<Massage>> getMessagesStream({
    required int compoundId,
    required int subscriberId,
  }) {
    return _firestore
        .collection("${Constants.company}${F.appCode}")
        .doc("${Constants.subscriberId}$subscriberId")
        .collection(Constants.chats)
        .doc("${Constants.compoundId}$compoundId")
        .collection(Constants.messages)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Massage.fromJson(doc.data())).toList();
    });
  }

  //set massage as seen
  Future<void> setMassageAsSeen({
    required int senderId,
    required String massageId,
    required int compoundId,
    required int subscriberId,
    required List<int> isSeenByList,
  }) async {
    try {
      //handle group massage as seen
      if (isSeenByList.contains(senderId)) {
        return;
      } else {
        //add the current user to isSeenByList in all massages
        await _firestore
            .collection("${Constants.company}${F.appCode}")
            .doc("${Constants.subscriberId}$subscriberId")
            .collection(Constants.chats)
            .doc("${Constants.compoundId}$compoundId")
            .collection(Constants.messages)
            .doc(massageId)
            .update({
          "isSeenBy": FieldValue.arrayUnion([senderId])
        });
      }
      emit(SetMassageAsSeenSuccess());
    } catch (e) {
      print("ErorrrrrrrrrrrrrrrrrrrrSetMassageAsSeen${e.toString()}");
      emit(SetMassageAsSeenError(message: e.toString()));
    }
  }

  //send reactions to massage
  FutureOr<void> _onSelectReactionEven(
      SelectReactionEvent event, Emitter<ChatsState> emit) async {
    emit(SendReactionsToMassageLoading());
    try {
      //save reaction as $senderId=$reaction
      final String reactionToAdd = "${event.senderId}=${event.reaction}";
      //check if group massage and send to group else send to contact
      //get reactions of massage list from firestore
      final massageData = await _firestore
          .collection("${Constants.company}${F.appCode}")
          .doc("${Constants.subscriberId}${event.subscriberId}")
          .collection(Constants.chats)
          .doc("${Constants.compoundId}${event.compoundId}")
          .collection(Constants.messages)
          .doc(event.massageId)
          .get();
      //add the massage data to massage
      final massage = Massage.fromJson(massageData.data()!);
      //check if reactions list empty
      if (massage.reactions.isEmpty) {
        //add reaction to massage
        await _firestore
            .collection("${Constants.company}${F.appCode}")
            .doc("${Constants.subscriberId}${event.subscriberId}")
            .collection(Constants.chats)
            .doc("${Constants.compoundId}${event.compoundId}")
            .collection(Constants.messages)
            .doc(event.massageId)
            .update({
          Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
        });
      } else {
        //get UIDS list from reactions
        final List<String> UIDS =
            massage.reactions.map((e) => e.split("=")[0]).toList();
        //check if reaction already added
        if (UIDS.contains(event.senderId)) {
          //get index of reaction
          final int index = UIDS.indexOf(event.senderId);
          //replace reaction
          massage.reactions[index] = reactionToAdd;
        } else {
          //add reaction
          massage.reactions.add(reactionToAdd);
        }
        //update massage
        await _firestore
            .collection("${Constants.company}${F.appCode}")
            .doc("${Constants.subscriberId}${event.subscriberId}")
            .collection(Constants.chats)
            .doc("${Constants.compoundId}${event.compoundId}")
            .collection(Constants.messages)
            .doc(event.massageId)
            .update({Constants.reactions: massage.reactions});
      }
      emit(SendReactionsToMassageSuccess());
    } catch (e) {
      print("ErorrrrrrrrrrrrrrrrrrrrSendReactionsToMassage${e.toString()}");
      emit(SendReactionsToMassageError(message: e.toString()));
    }
  }

  //get unread massages stream
  Stream<int> getUnreadMassagesStream({
    required String userId,
    //ToDO: equal to group id
    required int compoundId,
    required int subscriberId,
    required bool isGroup,
  }) {
    return _firestore
        .collection("${Constants.company}${F.appCode}")
        .doc("${Constants.subscriberId}$subscriberId")
        .collection(Constants.chats)
        .doc("${Constants.compoundId}$compoundId")
        .collection(Constants.messages)
        .snapshots()
        .asyncMap((event) {
      int count = 0;
      for (var element in event.docs) {
        final massage = Massage.fromJson(element.data());
        if (!massage.isSeenBy.contains(userId)) {
          count++;
        }
      }
      return count;
    });
  }

  FutureOr<void> _onDeleteMassageEvent(
      DeleteMassageEvent event, Emitter<ChatsState> emit) async {
    await deleteMessage(
      currentUserId: event.currentUserId,
      messageId: event.messageId,
      messageType: event.messageType,
      deleteForEveryone: event.deleteForEveryone,
      compoundId: event.compoundId,
      subscriberId: event.subscriberId,
      success: (message) {
        emit(DeleteMassageSuccess(massage: message));
      },
      failure: (message) {
        emit(DeleteMassageError(message: message));
      },
      setLoading: (isLoading) {
        emit(DeleteMassageLoading());
      },
    );
  }

  // delete message
  Future<void> deleteMessage({
    required int currentUserId,
    required String messageId,
    required String messageType,
    required bool deleteForEveryone,
    required int compoundId,
    required int subscriberId,
    required void Function(String message) success,
    required void Function(String message) failure,
    required void Function(bool isLoading) setLoading,
  }) async {
    // set loading
    setLoading(true);
    try {
      // handle group message
      await _firestore
          .collection("${Constants.company}${F.appCode}")
          .doc("${Constants.subscriberId}$subscriberId")
          .collection(Constants.chats)
          .doc("${Constants.compoundId}$compoundId")
          .collection(Constants.messages)
          .doc(messageId)
          .update({
        "isDeletedBy": FieldValue.arrayUnion([currentUserId])
      });
      // is is delete for everyone and message type is not text, we also delete the file from storage
      if (deleteForEveryone) {
        // update the message as deleted for everyone
        await _firestore
            .collection("${Constants.company}${F.appCode}")
            .doc("${Constants.subscriberId}$subscriberId")
            .collection(Constants.chats)
            .doc("${Constants.compoundId}$compoundId")
            .collection(Constants.messages)
            .doc(messageId)
            .update({
          "isDeletedBy": FieldValue.arrayUnion([-1]),
        });

        if (messageType != MassageType.text.name) {
          // delete the file from storage
          await deleteFileFromStorage(
            currentUserId: currentUserId,
            compoundId: compoundId.toString(),
            messageId: messageId,
            messageType: messageType,
          );
        }
        // set loading to false
        setLoading(false);
        success("Message deleted successfully");
      }
    } catch (e) {
      // set loading to false
      setLoading(false);
      // return error
      failure(e.toString());
    }
  }

  Future<void> deleteFileFromStorage({
    required int currentUserId,
    required String compoundId,
    required String messageId,
    required String messageType,
  }) async {
    final firebaseStorage = FirebaseStorage.instance;
    // delete the file from storage
    await firebaseStorage
        .ref('chatFiles/$messageType/$currentUserId/$compoundId/$messageId${_getMediaExtension(messageType)}')
        .delete();
  }

  FutureOr<void> _onSendFileMessageEvent(
      SendFileMessageEvent event, Emitter<ChatsState> emit) async {
    emit(SendFileMessageLoading());
    try {
      //1-generate id to massage
      var massageId = const Uuid().v4();
      //2-check if massage is reply then add replied message to massage
      String repliedMessage = _massageReply?.massage ?? "";
      String repliedTo = _massageReply == null
          ? ""
          : _massageReply!.isMe
              ? S.current.you
              : _massageReply!.senderName;
      MassageType repliedMessageType =
          _massageReply?.massageType ?? MassageType.text;
      //3-upload file to storage
      String fileUrl = await saveImageToStorage(
        event.file,
        "chatFiles/${event.massageType.name}/${event.sender.userInformation.id}/${event.compoundId}/$massageId${_getMediaExtension(event.massageType.name)}",
      );
      //4-update massage model with replied message
      final massage = Massage(
        senderId: event.sender.userInformation.id,
        senderName: event.sender.userInformation.name,
        senderImage: event.sender.userInformation.image,
        receiverId: event.compoundId,
        massage: fileUrl,
        massageType: event.massageType,
        timeSent: DateTime.now(),
        messageId: massageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isDeletedBy: [],
        isSeenBy: [event.sender.userInformation.id],
      );
      //handle group massage
      await _firestore
          .collection("${Constants.company}${F.appCode}")
          .doc("${Constants.subscriberId}${event.subscriberId}")
          .collection(Constants.chats)
          .doc("${Constants.compoundId}${event.compoundId}")
          .collection(Constants.messages)
          .doc(massageId)
          .set(massage.toJson());
      //set massage reply to null
      setMassageReply(null);
      emit(SendFileMessageSuccess());
      //set reply to null
      setMassageReply(null);
    } catch (e) {
      print("ErorrrrrrrrrrrrrrrrrrrrSendFileMessageEvent${e.toString()}");
      emit(SendFileMessageError(message: e.toString()));
    }
  }

  FutureOr<void> _onSelectImageEvent(
      SelectImageEvent event, Emitter<ChatsState> emit) {
    emit(SelectImageState(file: event.file));
  }

  FutureOr<void> _onSelectVideoFromGalleryEvent(
      SelectVideoFromGalleryEvent event, Emitter<ChatsState> emit) {
    emit(SelectVideoFromGalleryState(file: event.file));
  }

 String _getMediaExtension(String messageType) {
   //check media type
   String mediaExtension = ".jpg";
   switch (messageType) {
     case "image":
       mediaExtension = ".jpg";
       break;
     case "video":
       mediaExtension = ".mp4";
       break;
     case "audio":
       mediaExtension = ".m4a";
       break;
     case "file":
       mediaExtension = ".pdf";
       break;
   }
   return mediaExtension;
 }
}
