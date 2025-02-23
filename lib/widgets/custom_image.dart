// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// import '../constants/constants.dart';
// import '../constants/images_constant.dart';
// import 'custom_icon.dart';

// class CustomImageWidget extends StatelessWidget {
//   final String imageUrl;
//   final double? width;
//   final double? height;
//   final BoxFit fit;
//   final BorderRadius? borderRadius;
//   final Color? color; // New property for color overlay
//   final BlendMode? colorBlendMode; // New property for blend mode

//   // ignore: use_super_parameters
//   const CustomImageWidget({
//     Key? key,
//     required this.imageUrl,
//     this.width,
//     this.height,
//     this.fit = BoxFit.cover,
//     this.borderRadius,
//     this.color,
//     this.colorBlendMode,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: borderRadius ?? BorderRadius.circular(0),
//       child: CachedNetworkImage(
//         imageUrl: imageUrl.isEmpty ? ImagesPath.placeholder : imageUrl,
//         width: width,
//         height: height,
//         fit: fit,
//         placeholder: (context, url) => Container(
//             width: width,
//             height: height,
//             alignment: Alignment.center,
//             color: AppColors.disabledColor
//             // child: const CustomLoadingIndicator(),
//             ),
//         errorWidget: (context, url, error) => Container(
//           width: width,
//           height: height,
//           alignment: Alignment.center,
//           color: AppColors.disabledColor,
//           child: const CustomIconWidget(
//             iconData: Icons.error,
//             color: AppColors.errorColor,
//             size: 40,
//           ),
//         ),
//         // Adding color and blend mode to the image
//         color: color,
//         colorBlendMode: colorBlendMode,
//       ),
//     );
//   }
// }
