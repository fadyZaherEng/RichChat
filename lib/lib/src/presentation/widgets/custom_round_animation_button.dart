import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';

class CustomRoundedAnimationButton extends StatefulWidget {
  //rounded_loading_button
  bool isAnimated = false;
  bool isSuccess = false;
  bool isLoading = false;
  final double height;
  final double width;
  final double borderRadius;
  final Color valueColor;
  final Color successColor;
  final Color errorColor;
  Color? textColor = ColorSchemes.white;
  final Color borderColor;
  final double borderWidth;
  final IconData successIcon;
  final IconData errorIcon;
  final Function()? onTap;

  CustomRoundedAnimationButton({
    super.key,
    this.height = 48,
    this.width = 300,
    this.borderRadius = 25,
    required this.valueColor,
    required this.successColor,
    required this.errorColor,
    this.textColor,
    required this.borderColor,
    required this.borderWidth,
    this.successIcon = Icons.check,
    this.errorIcon = Icons.close,
    required this.onTap,
    this.isLoading = false,
    this.isSuccess = false,
    this.isAnimated = false,
  });

  @override
  State<CustomRoundedAnimationButton> createState() =>
      _CustomRoundedAnimationButtonState();
}

class _CustomRoundedAnimationButtonState
    extends State<CustomRoundedAnimationButton> {
  Color? backgroundColor;

  @override
  void initState() {
    super.initState();
    backgroundColor = Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
      height: widget.height,
      width: widget.isAnimated ? 50 : widget.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            alignment: Alignment.center,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
          onPressed: () async {
            // setState(() {
            //   widget.isAnimated = !widget.isAnimated;
            //   widget.isLoading = !widget.isLoading;
            // });
            // await Future.delayed(
            //     const Duration(milliseconds: 250)); //return from api time
            // setState(() {
            //   widget.isSuccess = !widget.isSuccess;
            //   widget.isLoading = !widget.isLoading;
            // });
            widget.onTap?.call();
          },
          child: widget.isAnimated
              ? widget.isLoading
                  ? const Center(
                      child: SizedBox(
                          height: 17,
                          width: 17,
                          child: CircularProgressIndicator(
                              color: ColorSchemes.white)))
                  : widget.isSuccess
                      ? Center(
                          child: Icon(widget.successIcon,
                              color: widget.valueColor))
                      : Center(
                          child:
                              Icon(widget.errorIcon, color: widget.errorColor))
              : Center(
                  child: Text(S.of(context).continues,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: widget.textColor))),
        ),
      ),
    );
  }
}
