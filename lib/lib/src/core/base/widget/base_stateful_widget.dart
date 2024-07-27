import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rich_chat_copilot/lib/src/core/base/manager/loading/loading_manager.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  final Color materialColor;

  const BaseStatefulWidget({
    Key? key,
    this.materialColor = Colors.white,
  }) : super(key: key);

  @override
  BaseState createState() {
    return baseCreateState();
  }

  BaseState baseCreateState();
}

abstract class BaseState<W extends BaseStatefulWidget> extends State<W>
    with LoadingManager {
  @override
  Widget build(BuildContext context) {
    return baseWidget();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget baseWidget() {
    return Material(
        color: widget.materialColor,
        child: Stack(
          fit: StackFit.expand,
          children: [baseBuild(context), loadingManagerWidget(context)],
        ));
  }

  void changeState() {
    setState(() {});
  }

  @override
  void runChangeState() {
    changeState();
  }

  Widget baseBuild(BuildContext context);
}
