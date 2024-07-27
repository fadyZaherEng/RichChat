import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_round_animation_button.dart';

class UserInfoBodyWidget extends StatelessWidget {
  final TextEditingController nameController;
  final void Function(String value) onChanged;
  final void Function() continuePressed;
  bool isAnimated = false;
  bool isSuccess = false;
  bool isLoading = false;

   UserInfoBodyWidget({
    super.key,
    required this.nameController,
    required this.onChanged,
    required this.continuePressed,
    this.isAnimated = false,
    this.isSuccess = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        TextFormField(
          controller: nameController,
          onChanged: (value) => onChanged(value),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: S.of(context).enterName,
            labelText: S.of(context).enterName,
          ),
        ),
        const SizedBox(height: 30),
        CustomRoundedAnimationButton(
          valueColor: ColorSchemes.white,
          successColor: Colors.green,
          errorColor: ColorSchemes.red,
          borderColor: Colors.transparent,
          borderWidth: 1,
          onTap: continuePressed,
          isAnimated: isAnimated,
          isLoading: isLoading,
          isSuccess: isSuccess,
        ),
      ],
    );
  }
}
