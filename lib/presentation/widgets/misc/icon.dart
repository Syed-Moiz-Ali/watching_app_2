import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

class CustomIconWidget extends StatelessWidget {
  const CustomIconWidget({
    super.key,
    this.imageUrl,
    this.iconData,
    this.width,
    this.height,
    this.scale,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.centerLeft,
    this.borderRadius,
    this.color,
    this.size = 20,
    this.colorBlendMode,
    this.onTap,
  });

  final Function()? onTap;
  final Alignment? alignment;
  final BorderRadius? borderRadius;
  final Color? color; // Color overlay
  final BlendMode? colorBlendMode; // Blend mode for color overlay
  final BoxFit fit;
  final double? height;
  final IconData? iconData; // For icon
  final String? imageUrl; // For image
  final double? scale;
  final double? size;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
      onTap: onTap ?? () {},
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: imageUrl != null
            ? Image.asset(
                imageUrl!,
                scale: scale,
                color: color,
                fit: fit,
                height: height,
                width: width,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.greyColor,
                    width: width,
                    height: height,
                  );
                },
              )
            // CustomImageWidget(
            //     imageUrl: imageUrl!,
            //     width: width,
            //     height: height,
            //     fit: fit,
            //     color: color,
            //     colorBlendMode: colorBlendMode,
            //   )
            : Icon(
                iconData,
                color: color,
                size:
                    size ?? width ?? height, // Use width or height as icon size
              ),
      ),
    );
  }
}
