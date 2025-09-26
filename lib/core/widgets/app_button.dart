import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../utils/font_constant.dart';
import 'app_text.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;
  final Color bgColor;
  final Color textColor;
  final String? label;
  final double borderRadius;
  final Widget? widget;
  final Border? border;
  const GradientButton({
    super.key,
    required this.onTap,
    this.height = 56,
    this.bgColor = AppColors.primaryColor,
    this.textColor = AppColors.whiteColor,
    this.borderRadius = 10,
    this.widget,
    this.label,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border),
        alignment: Alignment.center,
        child: widget ??
            AppText(
              label ?? 'Action',
              fontSize: 16,
              fontWeight: FontConstants.mediumFont,
              color: textColor,
            ),
      ),
    );
  }
}