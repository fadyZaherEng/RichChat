import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/cricle_loading_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/friend_widget.dart';

class GlobeScreen extends BaseStatefulWidget {
  const GlobeScreen({super.key});

  @override
  BaseState<GlobeScreen> baseCreateState() => _GlobeScreenState();
}

class _GlobeScreenState extends BaseState<GlobeScreen> {
  final _searchController = TextEditingController();
  UserModel currentUser = UserModel();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    currentUser = GetUserUseCase(injector())();
  }

  @override
  Widget baseBuild(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CupertinoSearchTextField(
              placeholder: S.of(context).search,
              prefixIcon: const Icon(CupertinoIcons.search),
              onTap: () {},
              onChanged: (value) {
                _searchController.text = value;
                setState(() {});
                //filter stream based on search
              },
              controller: _searchController,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseSingleTon.db
                  .collection(Constants.users)
                  .where(Constants.uId, isNotEqualTo: currentUser.uId)
                  .snapshots(),
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
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      S.of(context).noFoundUsersUntilNow,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorSchemes.gray,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 15);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      UserModel user =
                          UserModel.fromJson(snapshot.data!.docs[index].data());
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(start: 0),
                        child: FriendWidget(
                          friend: user,
                          friendViewType: FriendViewType.allUsers,
                          groupId: "",
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    ));
  }
}
