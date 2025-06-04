import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/text_styles.dart';
import 'package:flutter/material.dart';

final _base = ThemeData.light();
final _baseDark = ThemeData.dark();

final ThemeData lightTheme = _base.copyWith(
  //colors
  scaffoldBackgroundColor: lightBackgroundColor,
  primaryColor: primaryColor,
  canvasColor: primaryColor,
  dialogBackgroundColor: lightGrey,
  disabledColor: disabledColor,
  focusColor: primaryColor,
  hintColor: textPrimaryColor,
  hoverColor: lightGrey,
  indicatorColor: selectedColor,
  primaryColorDark: darkPrimaryColor,
  colorScheme: _base.colorScheme.copyWith(
    primary: primaryColor,
    secondary: selectedColor,
    onSurface: textPrimaryColor,
    onPrimary: textPrimaryColor,
    onPrimaryContainer: textPrimaryColor,
  ),

  //widgets
  elevatedButtonTheme: buttonStyle(),
  inputDecorationTheme: inputTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
  ),
  iconButtonTheme:
      IconButtonThemeData(style: ButtonStyle(foregroundColor: WidgetStateProperty.all<Color>(textPrimaryColor))),
);

final ThemeData darkTheme = _baseDark.copyWith(
  //colors
  scaffoldBackgroundColor: darkBackgroundColor,
  primaryColor: darkPrimaryColor,
  canvasColor: darkPrimaryColor,
  dialogBackgroundColor: darkGrey,
  disabledColor: darkDisabledColor,
  focusColor: darkPrimaryColor,
  hintColor: darkTextPrimaryColor,
  hoverColor: darkSelectedColor,
  indicatorColor: darkSelectedColor,
  colorScheme: _base.colorScheme.copyWith(
    primary: darkPrimaryColor,
    secondary: darkSelectedColor,
    onSurface: darkTextPrimaryColor,
    onPrimary: darkTextPrimaryColor,
    onPrimaryContainer: darkTextPrimaryColor,
  ),

  //widgets
  elevatedButtonTheme: darkButtonStyle(),
  inputDecorationTheme: darkInputTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: darkPrimaryColor,
  ),
  iconButtonTheme:
      IconButtonThemeData(style: ButtonStyle(foregroundColor: WidgetStateProperty.all<Color>(darkTextPrimaryColor))),
);

//Button Themes
ElevatedButtonThemeData buttonStyle() {
  return ElevatedButtonThemeData(
      style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return mediumGrey;
        }
        return primaryColor;
      },
    ),
    foregroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return darkBackgroundColor;
        }
        return Colors.black;
      },
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    )),
  ));
}

ElevatedButtonThemeData darkButtonStyle() {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return darkGrey;
          }
          return darkPrimaryColor;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return mediumGrey;
          }
          return lightGrey;
        },
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      )),
    ),
  );
}

//Input Text Theme
InputDecorationTheme inputTextTheme() {
  return InputDecorationTheme(
    labelStyle: style_body.copyWith(color: darkGrey),
    hintStyle: style_body.copyWith(color: mediumGrey),
    floatingLabelStyle: style_body.copyWith(color: textPrimaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: darkGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: mediumGrey),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.red),
    ),
  );
}

InputDecorationTheme darkInputTextTheme() {
  return InputDecorationTheme(
    labelStyle: style_body.copyWith(color: lightGrey),
    hintStyle: style_body.copyWith(color: lightGrey),
    floatingLabelStyle: style_body.copyWith(color: darkTextPrimaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: lightGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: mediumGrey),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.red),
    ),
  );
}
