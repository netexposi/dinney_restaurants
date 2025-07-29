import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

final Color backgroundColor = const Color(0xffefeef3);
final Color primaryColor = const Color(0xff222222);
final Color secondaryColor = const Color(0xffcba76a);
final Color tertiaryColor = const Color(0xff8A8A8A);
// all good
final ButtonStyle blackButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    fixedSize: WidgetStateProperty.all<Size>(Size(80.w, 6.h)),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
    )
  );
// to adjust
final ButtonStyle outlinedBeige = ButtonStyle(
  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
  fixedSize: WidgetStateProperty.all<Size>(Size(80.w, 6.h)),
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp))),
  side: WidgetStateProperty.all(BorderSide(color: secondaryColor, width: 2.0)),
  overlayColor: WidgetStateProperty.all<Color>(secondaryColor.withOpacity(0.5))
);
final BoxShadow dropShadow = BoxShadow(
    color: Color(0x0D000000), // 5% opacity black (#000000 with 0.05 alpha)
    offset: Offset(23, 3), // x=2, y=2
    blurRadius: 6, // 20% blur interpreted as 4px
    spreadRadius: 0, // No spread for a clean drop shadow
  );



