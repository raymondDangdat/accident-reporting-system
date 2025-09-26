import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../utils/constants.dart';
import '../utils/font_constant.dart';


class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? letterSpacing;
  final double? height;
  final TextOverflow? overflow;
  final TextDecoration? textDecoration;

  const AppText(this.text,
      {super.key,
        this.fontSize,
        this.fontWeight,
        this.color,
        this.textAlign,
        this.maxLines,
        this.letterSpacing,
        this.height,
        this.overflow,
        this.textDecoration});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontSize: fontSize ?? 14,
        decoration: textDecoration,
        fontWeight: fontWeight ?? FontConstants.regularFont,
        color: color ?? AppColors.blackTextColor,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }
}

class GreyAppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? letterSpacing;
  final double? height;
  final TextOverflow? overflow;
  final TextDecoration? textDecoration;

  const GreyAppText(this.text,
      {super.key,
        this.fontSize,
        this.fontWeight,
        this.color,
        this.textAlign,
        this.maxLines,
        this.letterSpacing,
        this.height,
        this.overflow,
        this.textDecoration});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontSize: fontSize ?? 14,
        decoration: textDecoration,
        fontWeight: fontWeight ?? FontConstants.regularFont,
        color: color ?? AppColors.greyTextColor,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }
}
