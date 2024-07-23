import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/cricle_loading_widget.dart';

class PhoneNumberWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final void Function(String value) onChange;
  final Country selectedCountry;
  final void Function(Country) onChangedCountry;
  final void Function() sendOtpVerificationCode;
  final bool isLoading;

  const PhoneNumberWidget({
    super.key,
    required this.textEditingController,
    required this.onChange,
    required this.selectedCountry,
    required this.onChangedCountry,
    required this.sendOtpVerificationCode,
    required this.isLoading,
  });

  @override
  State<PhoneNumberWidget> createState() => _PhoneNumberWidgetState();
}

class _PhoneNumberWidgetState extends State<PhoneNumberWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.textEditingController,
        maxLength: 10,
        keyboardType: TextInputType.phone,
        // inputFormatters: [
        //   LengthLimitingTextInputFormatter(10),
        //   FilteringTextInputFormatter.digitsOnly.
        //   //deny zero
        // ],
        decoration: InputDecoration(
          label: Text(S.of(context).phoneNumber),
          hintText: '',
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: _buildPrefixWidget(context),
          suffixIcon: widget.textEditingController.text.length > 9
              ? _buildSuffixWidget(context)
              : const SizedBox.shrink(),
        ),
        onChanged: (value) {
          if (value.startsWith("0")) {
            widget.textEditingController.text = value.substring(1);
            value = widget.textEditingController.text;
          }
          widget.onChange(value);
        });
  }

  Widget _buildPrefixWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          showCountryPicker(
            context: context,
            showPhoneCode: true,
            countryListTheme: CountryListThemeData(
              backgroundColor: ColorSchemes.white,
              textStyle: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: Constants.fontWeightMedium,
                color: ColorSchemes.black,
              ),
              inputDecoration: InputDecoration(
                  hintText: S.of(context).search,
                  hintStyle: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: Constants.fontWeightMedium,
                    color: ColorSchemes.black,
                  ),
                  prefixIcon: const Icon(CupertinoIcons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.7,
            ),
            onSelect: (Country country) {
              widget.onChangedCountry(country);
            },
          );
        },
        child: Text(
          '${widget.selectedCountry.flagEmoji} +${widget.selectedCountry.phoneCode}',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: Constants.fontWeightMedium,
            color: ColorSchemes.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSuffixWidget(BuildContext context) {
    return widget.isLoading
        ? const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircleLoadingWidget(),
            ))
        : InkWell(
            onTap: () {
              widget.sendOtpVerificationCode();
            },
            child: Container(
              height: 30,
              width: 30,
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: ColorSchemes.green,
                shape: BoxShape.circle,
              ),
              child:  const Icon(
                Icons.done,
                color: ColorSchemes.white,
                size: 25,
              ),
            ),
          );
  }
}
