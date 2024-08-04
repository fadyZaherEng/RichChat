import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/utils/massage_type.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/domain/entities/chat/massage_reply.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/display_massage_type_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/massage_to_show_widget.dart';
import 'package:flutter/material.dart';

class MassageReplyPreviewWidget extends StatelessWidget {
  final MassageReply? massageReply;
  final Massage? massage;
  final bool isShowCloseButton;
  final void Function() setReplyMessageWithNull;

  const MassageReplyPreviewWidget({
    super.key,
    this.massageReply,
    this.massage,
    required this.isShowCloseButton,
    required this.setReplyMessageWithNull,
  });

  @override
  Widget build(BuildContext context) {
    final type =
        massageReply != null ? massageReply!.massageType : massage!.massageType;

    final padding = massageReply != null
        ? const EdgeInsets.all(10)
        : const EdgeInsets.only(top: 5, right: 5, bottom: 5);

    return IntrinsicHeight(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: ColorSchemes.blueDivider,
          border:Border(
            top: BorderSide(color: ColorSchemes.primary, width: 1),
            left: BorderSide(color: ColorSchemes.primary, width: 1),
            right: BorderSide(color: ColorSchemes.primary, width: 1),
          ),
          borderRadius: massageReply != null
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))
              : const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              decoration:  BoxDecoration(
                color: ColorSchemes.iconBackGround,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _namedAndTypeWidget(type: type, context: context),
            const Spacer(),
            if(isShowCloseButton)
            _closedButtonWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _getTitle(context) {
    if (massageReply != null) {
      bool isMe = massageReply!.isMe;
      return Text(
        isMe ? S.of(context).you : massageReply!.senderName,
        style: Theme.of(context).textTheme.bodyMedium
      );
    } else {
      return Text(
        massage!.repliedTo,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
  }

  Widget _closedButtonWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        //TODO: set reply to null
        setReplyMessageWithNull();
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: ColorSchemes.iconBackGround,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: ColorSchemes.primary,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.close,
          size: 18,
        ),
      ),
    );
  }

  Widget _namedAndTypeWidget({
    required MassageType type,
    required BuildContext context,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getTitle(context),
          const SizedBox(height: 5),
          massageReply != null
              ? MassageToShowWidget(
                  massage: massageReply!.massage,
                  massageType: type,
                  )
              : DisplayMassageTypeWidget(
                  massage: massage!.massage,
                  isReplying: true,
                  massageType: type,
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  color: ColorSchemes.white,
                 ),
        ],
      ),
    );
  }
}
