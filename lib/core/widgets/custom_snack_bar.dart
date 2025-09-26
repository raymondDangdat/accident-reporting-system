import 'package:ars/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import '../colors/app_colors.dart';
import '../utils/font_constant.dart';

/// Show a top snackbar with centered icon + message.
/// If [svgAsset] is null/empty, only message is shown centered.
void customSnackBar(
    BuildContext context,
    String message, {
      bool isError = true,
      String? icon,
      Duration duration = const Duration(seconds: 3),
    }) {
  final overlay = Overlay.of(context);
  if (overlay == null) return; // nothing we can do

  showTopSnackBar(
    overlay,
    Material(
      color: Colors.transparent, // ensure rounding / shadows render correctly
      child: SafeArea(
        child: Center(
          // Center horizontally in the top overlay area
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFB52B46) : AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            // Ensure the content sizes to its children (not full width)
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 14,
                      fontWeight: FontConstants.mediumFont,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    displayDuration: duration,
    // optionally set animationType etc.
  );
}