import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watching_app_2/core/global/globals.dart';

import '../../../core/enums/enums.dart';

class TextWidget extends StatelessWidget {
  final Color? color;
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextStyleType styleType;
  final int? maxLine;
  final TextDecoration? decoration;
  final TextOverflow? overflow;

  const TextWidget({
    super.key,
    required this.text,
    this.color,
    this.fontSize, // Removed default value
    this.fontWeight,
    this.textAlign,
    this.styleType = TextStyleType.body1,
    this.maxLine = 1,
    this.decoration,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Set a default font size if not provided
    final double effectiveFontSize = fontSize ?? SMA.size.width * .038;

    TextStyle baseStyle = GoogleFonts.plusJakartaSans(
      fontSize: effectiveFontSize,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      decoration: decoration,
    );

    TextStyle textStyle;

    switch (styleType) {
      // Heading styles
      case TextStyleType.heading:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize * 2, // Base heading size
          fontWeight: FontWeight.bold,
        );
        break;
      case TextStyleType.heading1:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.8, // Larger heading font size
          fontWeight: FontWeight.bold,
        );
        break;
      case TextStyleType.heading2:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.6, // Smaller heading font size
          fontWeight: FontWeight.bold,
        );
        break;

      // Subheading styles
      case TextStyleType.subheading:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.5, // Base subheading size
          fontWeight: FontWeight.w600,
        );
        break;
      case TextStyleType.subheading1:
        textStyle = baseStyle.copyWith(
          fontSize:
              effectiveFontSize * 1.4, // Slightly larger subheading font size
          fontWeight: FontWeight.w600,
        );
        break;
      case TextStyleType.subheading2:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.3, // Smaller subheading font size
          fontWeight: FontWeight.w600,
        );
        break;

      // Body styles
      case TextStyleType.body:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize, // Base body size
        );
        break;
      case TextStyleType.body1:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize * .9, // Standard body size
        );
        break;
      case TextStyleType.body2:
        textStyle = baseStyle.copyWith(
          fontSize: effectiveFontSize * 0.8, // Smaller body size
        );
        break;

      default:
        textStyle = baseStyle;
        break;
    }

    return Text(
      softWrap: true,
      text,
      textAlign: textAlign ?? TextAlign.start,
      style: textStyle,
      maxLines: maxLine,
      overflow: overflow,
    );
  }
}
