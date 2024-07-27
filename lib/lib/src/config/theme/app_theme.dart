// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
// import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
//
// class AppTheme {
//   String language;
//
//   AppTheme(this.language);
//
//   ThemeData get light {
//     return ThemeData(
//       useMaterial3: false,
//       fontFamily: getFontFamily(),
//       toggleableActiveColor: ColorSchemes.primary,
//       appBarTheme: AppBarTheme(
//         centerTitle: true,
//         color: ColorSchemes.white,
//         elevation: 0.0,
//         shadowColor: Colors.transparent,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           systemNavigationBarColor: ColorSchemes.primary,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         contentPadding: const EdgeInsets.all(8),
//         hintStyle: TextStyle(
//             fontSize: 14,
//             fontFamily: getFontFamily(),
//             color: ColorSchemes.gray,
//             letterSpacing: 0.26,
//             fontWeight: FontWeight.normal),
//         labelStyle: TextStyle(
//             fontSize: 14,
//             fontFamily: getFontFamily(), //todo handle font family
//             color: ColorSchemes.gray,
//             fontWeight: FontWeight.normal),
//         errorStyle: TextStyle(
//             fontSize: 12,
//             fontFamily: getFontFamily(), //todo handle font family
//             color: ColorSchemes.redError,
//             fontWeight: FontWeight.normal),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: ColorSchemes.gray, width: 1),
//           borderRadius: BorderRadius.all(
//             Radius.circular(10),
//           ),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: ColorSchemes.gray, width: 1),
//           borderRadius: BorderRadius.all(
//             Radius.circular(10),
//           ),
//         ),
//         errorBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: ColorSchemes.redError, width: 1),
//           borderRadius: BorderRadius.all(
//             Radius.circular(10),
//           ),
//         ),
//         focusedErrorBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: ColorSchemes.redError, width: 1),
//           borderRadius: BorderRadius.all(
//             Radius.circular(10),
//           ),
//         ),
//         alignLabelWithHint: true,
//       ),
//       textTheme: TextTheme(
//         titleLarge: getTextStyle(
//           fontSize: 18,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightSemiBold,
//           color: ColorSchemes.primary,
//         ),
//         bodyLarge: getTextStyle(
//           fontSize: 16,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightSemiBold,
//           color: ColorSchemes.primary,
//         ),
//         bodyMedium: getTextStyle(
//           fontSize: 13,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightMedium,
//           color: ColorSchemes.primary,
//         ),
//         bodySmall: getTextStyle(
//           fontSize: 13,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           textDecoration: TextDecoration.none,
//           color: ColorSchemes.primary,
//         ),
//         labelLarge: getTextStyle(
//           fontSize: 12,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           color: ColorSchemes.primary,
//         ), //Regular
//       ),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: ColorSchemes.white,
//         selectedItemColor: ColorSchemes.primary,
//         selectedIconTheme: IconThemeData(color: ColorSchemes.primary, size: 24),
//         unselectedItemColor: ColorSchemes.gray,
//         unselectedLabelStyle: getTextStyle(
//           fontSize: 12,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           color: ColorSchemes.iconBackGround,
//         ),
//         selectedLabelStyle: getTextStyle(
//           fontSize: 12,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           color: ColorSchemes.primary,
//         ),
//         elevation: 10,
//         unselectedIconTheme: const IconThemeData(
//           color: ColorSchemes.gray,
//           size: 24,
//         ),
//       ),
//       scaffoldBackgroundColor: Colors.white,
//       primaryColor: ColorSchemes.primary,
//       splashColor: Colors.transparent,
//     );
//   }
//
//   ThemeData get dark => ThemeData(
//       useMaterial3: false,
//       fontFamily: getFontFamily(),
//       toggleableActiveColor: ColorSchemes.white,
//       primarySwatch: Colors.pink,
//       scaffoldBackgroundColor: HexColor('000028'),
//       appBarTheme: AppBarTheme(
//         backgroundColor: HexColor('00028'),
//         elevation: 0,
//         titleTextStyle: const TextStyle(
//           fontSize: 17.0,
//           fontWeight: FontWeight.bold,
//           color: Colors.pink,
//         ),
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: HexColor('000028'),
//           statusBarIconBrightness: Brightness.light,
//         ),
//         iconTheme: const IconThemeData(
//           color: Colors.pink,
//         ),
//         actionsIconTheme: const IconThemeData(
//           color: Colors.pink,
//         ),
//       ),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         elevation: 0.0,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: HexColor('000028'),
//         selectedItemColor: ColorSchemes.primary,
//         selectedIconTheme: IconThemeData(color: ColorSchemes.primary, size: 24),
//         unselectedIconTheme: const IconThemeData(
//           color: ColorSchemes.gray,
//           size: 24,
//         ),
//         unselectedItemColor: ColorSchemes.gray,
//         unselectedLabelStyle: getTextStyle(
//           fontSize: 12,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           color: ColorSchemes.iconBackGround,
//         ),
//         selectedLabelStyle: getTextStyle(
//           fontSize: 12,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           color: ColorSchemes.primary,
//         ),
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(),
//       textTheme: TextTheme(
//         titleLarge: getTextStyle(
//           fontSize: 18,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightSemiBold,
//           color: ColorSchemes.white,
//         ),
//         bodyLarge: getTextStyle(
//           fontSize: 16,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightSemiBold,
//           color: ColorSchemes.white,
//         ),
//         bodyMedium: getTextStyle(
//           fontSize: 13,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightMedium,
//           color: ColorSchemes.white,
//         ),
//         bodySmall: getTextStyle(
//           fontSize: 13,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           textDecoration: TextDecoration.none,
//           color: ColorSchemes.white,
//         ),
//         labelLarge: getTextStyle(
//           fontSize: 12,
//           fontFamily: getFontFamily(),
//           fontWeight: Constants.fontWeightRegular,
//           color: ColorSchemes.white,
//         ),
//       ),
//       cardTheme: CardTheme(
//         color: HexColor('180040'),
//       ),
//       hintColor: Colors.white,
//       brightness: Brightness.dark,
//       primaryColor: Colors.white,
//       drawerTheme: DrawerThemeData(
//         elevation: 0,
//         backgroundColor: HexColor('000028'),
//       ),
//       bottomSheetTheme:
//           BottomSheetThemeData(backgroundColor: HexColor('000028')));
//
//   String getFontFamily() => language == "en"
//       ? Constants.englishFontFamily
//       : Constants.arabicFontFamily;
//
//   static TextStyle getTextStyle({
//     double fontSize = 24,
//     FontWeight fontWeight = FontWeight.normal,
//     String fontFamily = Constants.englishFontFamily,
//     required Color color,
//     textDecoration = TextDecoration.none,
//   }) {
//     return TextStyle(
//         fontFamily: fontFamily,
//         fontWeight: fontWeight,
//         fontSize: fontSize,
//         color: color,
//         decoration: textDecoration);
//   }
// }
