import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:city_eye/src/core/utils/massage_type.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/domain/entities/chat/massage_reply.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/display_massage_type_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/massage_reply_preview_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/stacked_reactions_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class ReceiverMassageWidget extends StatelessWidget {
  final Massage massage;
  final bool isReplying;
  final void Function() setMassageReplyNull;

  const ReceiverMassageWidget({
    super.key,
    required this.massage,
    required this.isReplying,
    required this.setMassageReplyNull,
  });

  @override
  Widget build(BuildContext context) {
    final padding = massage.reactions.isNotEmpty
        ? const EdgeInsets.only(right: 20.0, bottom: 25.0)
        : const EdgeInsets.only(bottom: 0.0);
    final massageReactions =
        massage.reactions.map((e) => e.split("=")[1]).toList();
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: massageReactions.length > 2
                ? MediaQuery.of(context).size.width * 0.3
                : MediaQuery.of(context).size.width * 0.15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, top: 5),
              child: InkWell(
                onTap: () {},
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorSchemes.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      massage.senderImage,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SvgPicture.asset(
                            ImagePaths.avatar,
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SkeletonLine(
                            style: SkeletonLineStyle(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Padding(
                    padding: padding,
                    child: Card(
                      elevation: 5,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      color: ColorSchemes.iconBackGround,
                      child: Stack(
                        children: [
                          Padding(
                            padding: massage.massageType == MassageType.text
                                ? const EdgeInsets.fromLTRB(10, 5, 10, 10)
                                : const EdgeInsets.fromLTRB(5, 5, 5, 10),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isReplying) ...[
                                    MassageReplyPreviewWidget(
                                      massageReply: MassageReply(
                                        isMe: false,
                                        senderId: massage.senderId.toString(),
                                        senderName: massage.senderName,
                                        massage: massage.repliedMessage,
                                        massageType: massage.repliedMessageType,
                                        senderImage: massage.senderImage,
                                      ),
                                      setReplyMessageWithNull: () {
                                        setMassageReplyNull();
                                      },
                                      isShowCloseButton: false,
                                    )
                                  ],
                                  DisplayMassageTypeWidget(
                                    massageType: massage.massageType,
                                    massage: massage.massage,
                                    color: ColorSchemes.black,
                                    isReplying: false,
                                  ),
                                  Text(
                                    DateFormat("hh:mm a").format(massage.timeSent),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: ColorSchemes.gray),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Positioned(
                  //     bottom: 0,
                  //     left: 50,
                  //     child: //TODO: Add Package StackedReactions
                  //         StackedReactions(
                  //       reactions: massageReactions,
                  //     )
                  //TODO: Add My StackedReactionsWidget
                  Positioned(
                    bottom: 5,
                    left: 30,
                    child: StackedReactionsWidget(
                      massage: massage,
                      size: 22,
                      onPressed: () {
                        //Todo: show bottom sheet with list of people reactions with massage
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
