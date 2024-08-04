import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/utils/show_bottom_sheet.dart';
import 'package:flutter/material.dart';

void showDeleteBottomSheet({
  required bool isSender,
  required BuildContext context,
  required bool isLoading,
  required Function({required bool deleteForEveryoneOrNot}) onDelete,
}) {
  showBottomSheetWidget(
    context: context,
    content: SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              leading: Icon(Icons.delete, color: ColorSchemes.primary),
              title: Text(S.of(context).deleteForMe,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: ColorSchemes.black)),
              onTap: isLoading
                  ? null
                  : () async {
                      onDelete(deleteForEveryoneOrNot: false);
                    }),
          isSender
              ? ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: ColorSchemes.primary,
                  ),
                  title: Text(S.of(context).deleteForAll,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: ColorSchemes.black)),
                  onTap: isLoading
                      ? null
                      : () async {
                          onDelete(deleteForEveryoneOrNot: true);
                        },
                )
              : const SizedBox.shrink(),
          ListTile(
            leading: Icon(Icons.cancel, color: ColorSchemes.primary),
            title: Text(S.of(context).cancel,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: ColorSchemes.black)),
            onTap: isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
    ),
    titleLabel: S.of(context).delete,
  );
}
