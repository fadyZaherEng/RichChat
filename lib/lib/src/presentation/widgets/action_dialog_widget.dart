import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';

class ActionDialogWidget extends StatelessWidget {
  final String text;
  final String icon;
  final String primaryText;
  final String secondaryText;
  final Function() primaryAction;
  final Function() secondaryAction;
  final Color? iconColor;
  IconData? iconData;

   ActionDialogWidget({
    Key? key,
    required this.text,
    required this.icon,
    required this.primaryText,
    required this.secondaryText,
    this.iconColor,
    required this.iconData,
    required this.primaryAction,
    required this.secondaryAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorSchemes.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: icon.isNotEmpty,
                child: SvgPicture.asset(
                  icon,
                  fit: BoxFit.scaleDown,
                  width: 48,
                  height: 48,
                  color: iconColor,
                ),
              ),
              Visibility(
                  visible: icon.isNotEmpty,
                  child: const SizedBox(
                    height: 16.2,
                  )),
              Visibility(
                visible: iconData != null,
                child: Icon(
                  iconData,
                  color: iconColor,
                ),
              ),
              Visibility(
                  visible: iconData != null,
                  child: const SizedBox(
                    height: 16.2,
                  )),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: ColorSchemes.black,
                      letterSpacing: -0.24,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 32.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: ColorSchemes.gray),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: ColorSchemes.white,
                                  letterSpacing: -0.24,
                                  fontSize: 15,
                                ),
                      ),
                      onPressed: primaryAction,
                      child: Text(
                        primaryText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: ColorSchemes.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 23,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: ColorSchemes.gray),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: ColorSchemes.white,
                                  letterSpacing: -0.24,
                                  fontSize: 15,
                                ),
                      ),
                      onPressed: secondaryAction,
                      child: Text(
                        secondaryText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: ColorSchemes.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
