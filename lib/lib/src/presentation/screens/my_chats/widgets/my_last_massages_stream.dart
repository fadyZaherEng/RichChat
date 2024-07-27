import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/last_massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/cricle_loading_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/last_massage_chat_widget.dart';

class MyChatsStream extends StatelessWidget {
  final Stream<List<LastMassage>> myChatsStream;
  const MyChatsStream({super.key,required this.myChatsStream,});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LastMassage>>(
      stream:myChatsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleLoadingWidget();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              S.of(context).somethingWentWrong,
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorSchemes.gray,
              ),
            ),
          );
        }
        if (!snapshot.hasData ||
            snapshot.data!.isEmpty ||
            snapshot.data == null) {
          return Center(
            child: Text(
              S.of(context).noFoundChatsUntilNow,
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: ColorSchemes.black,
              ),
            ),
          );
        }
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final chats = snapshot.data![index];
                return LastMassageChatWidget(
                  chats: chats,
                  isGroup: false,
                  onTap: () {
                    //TODO: navigate to chat screen
                    Navigator.pushNamed(
                      context,
                      Routes.chatWithFriendScreen,
                      arguments: {
                        "friendId": chats.receiverId,
                        "friendName": chats.receiverName,
                        "friendImage": chats.receiverImage,
                        "groupId": ""
                      },
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            ),
          );
        } else {
          return const Center(
            child: Text("No Chats Found"),
          );
        }
      },
    );
  }
}
