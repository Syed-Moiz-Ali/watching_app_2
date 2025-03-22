import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/core/enums/enums.dart';
import 'dart:ui' as ui;

class TextWidget extends StatefulWidget {
  final Color? color;
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextStyleType styleType;
  final int? maxLine;
  final TextDecoration? decoration;
  final TextOverflow? overflow;
  final Duration? animationDuration;
  final bool animate;
  final TextEffect textEffect;
  final bool enableGradient;
  final List<Color>? gradientColors;
  final TextStyle? customStyle;
  final double letterSpacing;
  final double wordSpacing;
  final double? height;
  final VoidCallback? onTap;
  final bool shimmerEffect;

  const TextWidget({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.styleType = TextStyleType.body1,
    this.maxLine,
    this.decoration,
    this.overflow,
    this.animationDuration,
    this.animate = false,
    this.textEffect = TextEffect.none,
    this.enableGradient = false,
    this.gradientColors,
    this.customStyle,
    this.letterSpacing = 0.0,
    this.wordSpacing = 0.0,
    this.height,
    this.onTap,
    this.shimmerEffect = false,
  });

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? const Duration(milliseconds: 500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _animationController.forward(from: 0.0);
      } else {
        _animationController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive font size with safety checks
    final double effectiveFontSize = widget.fontSize ??
        (SMA.size.width * .038).clamp(12.0, 40.0); // Clamped for safety

    // Base style with enhanced typography
    TextStyle baseStyle = widget.customStyle ??
        GoogleFonts.plusJakartaSans(
          fontSize: effectiveFontSize,
          fontWeight: widget.fontWeight ?? FontWeight.w500,
          color: widget.color ?? Theme.of(context).colorScheme.onSurface,
          decoration: widget.decoration,
          letterSpacing: widget.letterSpacing,
          wordSpacing: widget.wordSpacing,
          height: widget.height,
          shadows: widget.textEffect == TextEffect.shadow
              ? [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ]
              : null,
        );

    // Apply style variations based on type
    TextStyle textStyle = _getStyleByType(baseStyle, effectiveFontSize);

    // Build the text widget with animations
    Widget textWidget = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        Widget result = child!;

        // Apply animation effects
        if (widget.animate) {
          result = Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.translate(
              offset: Offset(0.0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          );
        }

        return result;
      },
      child: _buildRichText(textStyle),
    );

    // Apply tap detector if onTap is provided
    if (widget.onTap != null) {
      textWidget = GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: textWidget,
      );
    }

    return textWidget;
  }

  Widget _buildRichText(TextStyle textStyle) {
    // Handle shimmer effect if enabled
    if (widget.shimmerEffect) {
      return ShimmerEffect(
        child: Text(
          widget.text,
          textAlign: widget.textAlign ?? TextAlign.start,
          style: textStyle,
          maxLines: widget.maxLine,
          overflow: widget.overflow,
          softWrap: true,
        ),
      );
    }

    // Handle gradient text if enabled
    if (widget.enableGradient) {
      final List<Color> colors = widget.gradientColors ??
          [
            Colors.blue.shade500,
            Colors.purple.shade500,
          ];

      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) {
          return ui.Gradient.linear(
            Offset(0, 0),
            Offset(bounds.width, 0),
            colors,
            [0.0, 1.0],
          );
        },
        child: Text(
          widget.text,
          textAlign: widget.textAlign ?? TextAlign.start,
          style: textStyle,
          maxLines: widget.maxLine,
          overflow: widget.overflow,
          softWrap: true,
        ),
      );
    }

    // Handle typewriter effect
    if (widget.textEffect == TextEffect.typewriter) {
      return TypewriterText(
        text: widget.text,
        textStyle: textStyle,
        textAlign: widget.textAlign ?? TextAlign.start,
        maxLines: widget.maxLine,
        overflow: widget.overflow,
      );
    }

    // Standard text rendering
    return Text(
      widget.text,
      textAlign: widget.textAlign ?? TextAlign.start,
      style: textStyle,
      maxLines: widget.maxLine,
      overflow: widget.overflow,
      softWrap: true,
    );
  }

  TextStyle _getStyleByType(TextStyle baseStyle, double effectiveFontSize) {
    switch (widget.styleType) {
      // Heading styles with enhanced hierarchy
      case TextStyleType.heading:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 2.2,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.5,
        );
      case TextStyleType.heading1:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.8,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        );
      case TextStyleType.heading2:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.6,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.2,
        );

      // Subheading styles with refined typography
      case TextStyleType.subheading:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.1,
        );
      case TextStyleType.subheading1:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.4,
          fontWeight: FontWeight.w600,
          height: 1.35,
        );
      case TextStyleType.subheading2:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 1.3,
          fontWeight: FontWeight.w600,
          height: 1.4,
        );

      // Body styles with improved readability
      case TextStyleType.body:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize,
          height: 1.45,
          letterSpacing: 0.2,
        );
      case TextStyleType.body1:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 0.9,
          height: 1.5,
          letterSpacing: 0.15,
        );
      case TextStyleType.body2:
        return baseStyle.copyWith(
          fontSize: effectiveFontSize * 0.8,
          height: 1.55,
          letterSpacing: 0.1,
        );

      default:
        return baseStyle;
    }
  }
}

// Shimmer effect component
class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return ui.Gradient.linear(
              Offset(bounds.width * _shimmerController.value, 0),
              Offset(bounds.width * (_shimmerController.value + 0.5), 0),
              [
                Colors.grey.shade500,
                Colors.white,
                Colors.grey.shade500,
              ],
              [0.0, 0.5, 1.0],
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

// Typewriter effect component
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TypewriterText({
    required this.text,
    required this.textStyle,
    required this.textAlign,
    this.maxLines,
    this.overflow,
    Key? key,
  }) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _typewriterController;
  late Animation<int> _typewriterAnimation;

  @override
  void initState() {
    super.initState();
    _typewriterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.text.length * 100),
    );

    _typewriterAnimation = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(
        parent: _typewriterController,
        curve: Curves.easeOut,
      ),
    );

    _typewriterController.forward();
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _typewriterAnimation,
      builder: (context, child) {
        return Text(
          widget.text.substring(0, _typewriterAnimation.value),
          textAlign: widget.textAlign,
          style: widget.textStyle,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        );
      },
    );
  }
}

// Enum for text effects
enum TextEffect {
  none,
  shadow,
  typewriter,
}
