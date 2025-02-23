import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/color_constants.dart';
import 'text_widget.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.labelText,
      this.hintText,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.onSubmitted,
      this.contentPadding,
      this.prefixIcon,
      this.suffixIcon,
      this.enabled = true,
      this.isFilled = false,
      this.showBorder = true,
      this.filledColor,
      this.boxShadow,
      this.onChanged,
      this.obscureText,
      this.radius,
      this.focusNode,
      this.maxLength});

  final Function(String)? onChanged;
  final List<BoxShadow>? boxShadow;
  final TextEditingController controller;
  final bool? enabled;
  final Color? filledColor;
  final bool isFilled;
  final bool showBorder;
  final TextInputType keyboardType;
  final String labelText;
  final String? hintText;
  final FocusNode? focusNode;
  final int? maxLength;
  final dynamic onSubmitted;
  final Widget? prefixIcon;
  final double? radius;
  final Widget? suffixIcon;
  final dynamic validator;
  final bool? obscureText;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: boxShadow),
      child: TextFormField(
        enabled: enabled,
        focusNode: focusNode,
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        onChanged: onChanged,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.greyColor),
          counterStyle: const TextStyle(color: AppColors.transparent),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          label: TextWidget(
            text: labelText,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.6),
          ),
          // labelText: labelText,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius ?? 8),
              borderSide: BorderSide(
                  color: showBorder
                      ? AppColors.primaryColor
                      : AppColors.transparent)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius ?? 8),
              borderSide: BorderSide(
                  color: showBorder
                      ? AppColors.backgroundColorDark.withOpacity(.3)
                      : AppColors.transparent)),

          filled: isFilled,
          fillColor: filledColor,
        ),
        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}
