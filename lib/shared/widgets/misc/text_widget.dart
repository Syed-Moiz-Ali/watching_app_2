import 'package:flutter/material.dart';
import 'package:watching_app_2/core/global/globals.dart';

import '../../../core/constants/colors.dart';
import '../../../core/enums/enums.dart';

class TextWidget extends StatefulWidget {
  const TextWidget(
      {super.key,
      required this.text,
      this.color,
      this.fontSize = 16.0, // Default font size
      this.fontWeight,
      this.textAlign,
      this.styleType = TextStyleType.body, // Default style type
      this.maxLine = 1,
      this.namedArgs,
      this.decoration,
      this.useShader,
      this.letterSpacing,
      this.shadows});

  final Color? color;
  final double fontSize;
  final FontWeight? fontWeight;
  final int? maxLine;
  final Map<String, String>? namedArgs;
  final TextStyleType styleType; // New parameter for text style type
  final String text;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final List<Shadow>? shadows;
  final bool? useShader;
  final double? letterSpacing;

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var baseStyle = SMA.baseTextStyle(
        shadows: widget.shadows,
        fontSize: widget.fontSize,
        letterSpacing: widget.letterSpacing,
        color: widget.color ??
            Theme.of(SMA.navigationKey.currentContext!).colorScheme.onSurface,
        fontWeight: widget.fontWeight ?? FontWeight.w500,
        decoration: widget.decoration ?? TextDecoration.none);

    // Apply different styles based on the styleType
    TextStyle textStyle;
    switch (widget.styleType) {
      case TextStyleType.heading:
        textStyle = baseStyle.copyWith(
          fontSize: widget.fontSize * 1.5,
          fontWeight: FontWeight.bold,
          color: widget.color ?? Theme.of(context).colorScheme.onSurface,
        );
        break;
      case TextStyleType.subheading:
        textStyle = baseStyle.copyWith(
          fontSize: widget.fontSize * 1.2,
          fontWeight: FontWeight.w600,
          color: widget.color ?? Theme.of(context).colorScheme.onSurface,
        );
        break;
      case TextStyleType.body:
      default:
        textStyle = baseStyle;
        break;
    }

    if (widget.useShader ?? false) {
      return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.6),
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.6),
                  ],
                  stops: [0.0, _animation.value, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                widget.text,
                textAlign: widget.textAlign ?? TextAlign.start,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: widget.maxLine,
              ),
            );
          });
    } else {
      return Text(
        widget.text,
        textAlign: widget.textAlign ?? TextAlign.start,
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: widget.maxLine,
      );
    }
  }
}

// Enum to define text styles

