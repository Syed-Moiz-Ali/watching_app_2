import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/global/globals.dart';
import '../misc/text_widget.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    super.key,
    required this.onTap,
    this.text,
    this.width,
    this.height,
    this.elevation = 5,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.bgColor,
    this.padding,
    this.styleType,
    this.child,
    this.boxShadows,
    this.gradient,
    this.border,
  }) {
    // Ensure either text or icon is provided, but not both or none
    if ((text == null && child == null) || (text != null && child != null)) {
      throw ArgumentError(
          'Either text or child must be provided, but not both or none.');
    }
  }

  final Color? textColor, bgColor;
  final List<BoxShadow>? boxShadows;
  final double? borderRadius, elevation;
  final double? fontSize;
  final FontWeight? fontWeight;
  final LinearGradient? gradient;
  final double? height;
  final Widget? child;
  final VoidCallback onTap;
  final double? padding;
  final TextStyleType? styleType;
  final String? text;
  final double? width;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          elevation: elevation ?? 5,
          shape: RoundedRectangleBorder(
            side: border ?? BorderSide.none,
            borderRadius: BorderRadius.circular(borderRadius ?? 5),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: height == null
                ? SMA.size.height * .063
                : SMA.size.height * double.parse(height.toString()),
            alignment: Alignment.center,
            width: width == null
                ? SMA.size.width
                : SMA.size.width * double.parse(width.toString()),
            padding: EdgeInsets.all(padding ?? 0.0),
            decoration: BoxDecoration(
              gradient: bgColor == null ? gradient : null,
              color: bgColor ?? AppColors.primaryColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 5),
              boxShadow: boxShadows,
            ),
            child: child != null
                ? child!
                : Center(
                    child: TextWidget(
                      text: text!,
                      fontSize: fontSize ?? 15,
                      color: textColor ?? AppColors.backgroundColorLight,
                      styleType: styleType ?? TextStyleType.body,
                      fontWeight: fontWeight,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
