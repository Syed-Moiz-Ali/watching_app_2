// import 'package:flutter/material.dart';
// import 'package:watching_app_2/global/app_global.dart';

// import 'custom_icon.dart';
// import 'text_widget.dart';

// class CustomToast {
//   static void show({
//     required String message,
//     ToastType type = ToastType.info, // Default toast type
//   }) {
//     // Retrieve the current context safely
//     final context = SMA.navigationKey.currentContext;
//     if (context == null) return;

//     // Map toast types to corresponding icons and colors
//     IconData iconData = _getIconForToastType(type);
//     Color backgroundColor = _getToastColor(type);

//     toastification.showCustom(
//       context: context,
//       alignment: Alignment.bottomCenter,
//       autoCloseDuration: const Duration(seconds: 4),
//       builder: (context, item) {
//         return Container(
//           decoration: BoxDecoration(
//             color: backgroundColor,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           height: Aio.size.height * 0.07,
//           width: Aio.size.width,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           margin: const EdgeInsets.all(8),
//           child: Row(
//             children: [
//               CustomIconWidget(
//                 iconData: iconData,
//                 size: Aio.size.width * 0.06,
//                 color: AppColors.backgroundColorLight,
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextWidget(
//                   text: message,
//                   color: AppColors.backgroundColorLight,
//                   // overflow: TextOverflow.ellipsis,
//                   // maxLines: 2,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Helper function to get the appropriate icon for the toast type
//   static IconData _getIconForToastType(ToastType type) {
//     switch (type) {
//       case ToastType.success:
//         return Iconsax.tick_circle;
//       case ToastType.error:
//         return Iconsax.close_circle;
//       case ToastType.warning:
//         return Iconsax.warning_2;
//       case ToastType.info:
//       default:
//         return Iconsax.info_circle;
//     }
//   }

//   // Helper function to get the background color based on the toast type
//   static Color _getToastColor(ToastType type) {
//     switch (type) {
//       case ToastType.success:
//         return Aio.theme.colorScheme.primaryColor;
//       case ToastType.error:
//         return AppColors.errorColor;
//       case ToastType.warning:
//         return Colors.orange;
//       case ToastType.info:
//         return AppColors.primaryColor.withOpacity(.9);
//       default:
//         return Aio.theme.colorScheme.primaryColor;
//     }
//   }
// }

// // Enum for toast types
// enum ToastType {
//   info,
//   success,
//   error,
//   warning,
// }
