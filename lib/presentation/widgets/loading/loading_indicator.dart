import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.size, // size can be nullable
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size
    var finalColor = color ?? AppColors.primaryColor;
    // final double calculatedSize =
    //     size ?? MediaQuery.of(context).size.width * 0.1;

    return Center(
      child: CircularProgressIndicator(
        color: finalColor,
        // size: calculatedSize,
      ),
    );
  }
}
