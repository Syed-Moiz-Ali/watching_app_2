// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';


// class WidgetZoomFullscreen extends StatefulWidget {
//   final Widget zoomWidget;
//   final double minScale;
//   final double maxScale;
//   final Object heroAnimationTag;
//   final double? fullScreenDoubleTapZoomScale;
//   final dynamic title;
//   final dynamic icon;
//   final dynamic imageUrl;
//   const WidgetZoomFullscreen(
//       {Key? key,
//       required this.zoomWidget,
//       required this.minScale,
//       required this.maxScale,
//       required this.heroAnimationTag,
//       this.fullScreenDoubleTapZoomScale,
//       this.title = '',
//       this.imageUrl = '',
//       this.icon})
//       : super(key: key);

//   @override
//   State<WidgetZoomFullscreen> createState() => _ImageZoomFullscreenState();
// }

// class _ImageZoomFullscreenState extends State<WidgetZoomFullscreen>
//     with SingleTickerProviderStateMixin {
//   final TransformationController _transformationController =
//       TransformationController();
//   late AnimationController _animationController;
//   late double closingTreshold = MediaQuery.of(context).size.height /
//       5; //the higher you set the last value the earlier the full screen gets closed

//   Animation<Matrix4>? _animation;
//   double _opacity = 1;
//   double _imagePosition = 0;
//   Duration _animationDuration = Duration.zero;
//   Duration _opacityDuration = Duration.zero;
//   late double _currentScale = widget.minScale;
//   TapDownDetails? _doubleTapDownDetails;

//   @override
//   void initState() {
//     super.initState();
   
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     )..addListener(() => _transformationController.value = _animation!.value);
//   }

//   @override
//   void dispose() {
//     _transformationController.dispose();
//     _animationController.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: AnimatedOpacity(
//               duration: _opacityDuration,
//               opacity: _opacity,
//               child: Container(
//                 color: primaryColor,
//               ),
//             ),
//           ),
//           AnimatedPositioned(
//             duration: _animationDuration,
//             top: _imagePosition,
//             bottom: -_imagePosition,
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               height: 200,
//               child: InteractiveViewer(
//                 constrained: true,
//                 transformationController: _transformationController,
//                 minScale: widget.minScale,
//                 maxScale: widget.maxScale,
//                 onInteractionStart: _onInteractionStart,
//                 onInteractionUpdate: _onInteractionUpdate,
//                 onInteractionEnd: _onInteractionEnd,
//                 child: GestureDetector(
//                   // need to have both methods, otherwise the zoom will be triggered before the second tap releases the screen
//                   onDoubleTapDown: (details) => _doubleTapDownDetails = details,
//                   onDoubleTap: _zoomInOut,
//                   child: Hero(
//                     tag: widget.heroAnimationTag,
//                     child: widget.zoomWidget,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(left: 0, bottom: 20, right: 0, child: bottomStrip()),
//         ],
//       ),
//     );
//   }

//   Widget bottomStrip() {
//     return Container(
//       decoration: BoxDecoration(
//         color: primaryColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: greyColor.shade700, width: 1),
//       ),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       height: 60,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           _buildEnhancedButton(
//             icon: Icons.wallpaper_rounded,
//             label: 'Set Wallpaper',
//             onTap: () {
//               _showConfirmationDialog(widget.imageUrl, context);
//             },
//           ),
//           _buildEnhancedButton(
//             icon: Icons.download_rounded,
//             label: 'Download',
//             onTap: () {
//               SetImage().downloadImage(context, widget.imageUrl);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedButton(
//       {required IconData icon,
//       required String label,
//       required VoidCallback onTap}) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         overlayColor: const MaterialStatePropertyAll(Colors.transparent),
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         splashColor: secondaryColor.withOpacity(0.2),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//           decoration: BoxDecoration(
//             color: greyColor.shade900,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: primaryColor.withOpacity(0.5),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: secondaryColor, size: 22),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors
//                       .grey.shade400, // Use a subtle grey to soften the text
//                   fontSize: 14, // Slightly smaller, cleaner text
//                   fontWeight:
//                       FontWeight.w600, // Lighter weight for a minimalist look
//                   letterSpacing:
//                       0.5, // Small letter spacing to enhance readability
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _showConfirmationDialog(
//     String modifiedImage,
//     BuildContext context,
//   ) async {
//     await showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       backgroundColor: primaryColor, // Dark background for a sleek look
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Choose Wallpaper Screen',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: secondaryColor,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildOptionTile(
//                 icon: Icons.home,
//                 label: 'Home Screen',
//                 onTap: () {
//                   SetImage().setWallpaper(modifiedImage, 0, context);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               const SizedBox(height: 8),
//               _buildOptionTile(
//                 icon: Icons.lock,
//                 label: 'Lock Screen',
//                 onTap: () {
//                   SetImage().setWallpaper(modifiedImage, 1, context);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               const SizedBox(height: 8),
//               _buildOptionTile(
//                 icon: Icons.phone_android,
//                 label: 'Both Screens',
//                 onTap: () {
//                   SetImage().setWallpaper(modifiedImage, 2, context);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildOptionTile({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         overlayColor: const MaterialStatePropertyAll(Colors.transparent),
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12), // Rounded corners
//         splashColor: secondaryColor.withOpacity(0.1), // Subtle splash effect
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
//           decoration: BoxDecoration(
//             color: greyColor.shade800, // Dark grey for tiles
//             borderRadius: BorderRadius.circular(12),
//             // No shadow for a clean, flat look
//           ),
//           child: Row(
//             children: [
//               Icon(icon, size: 24, color: secondaryColor), // Modern icon size
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                     color: secondaryColor,
//                   ),
//                   overflow:
//                       TextOverflow.ellipsis, // Handle overflow with ellipsis
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildFloatingActionButtonChild() {
//     var provider = Provider.of<SetImageProvider>(context, listen: true);
//     if (provider.settingWallpaperIsLoading) {
//       return const SizedBox(
//         width: 25.0,
//         height: 25.0,
//         child: CustomLoadingIndicator(
//           color: secondaryColor,
//         ),
//       );
//     } else {
//       if (provider.isWallpaperSet) {
//         return const Icon(
//           Icons.done,
//           size: 30,
//           color: secondaryColor,
//         );
//       } else {
//         return const Icon(
//           Icons.wallpaper,
//           size: 30,
//           color: secondaryColor,
//         );
//       }
//     }
//   }

//   Widget buildFloatingActionButtonChildForDownload() {
//     var provider = Provider.of<SetImageProvider>(context, listen: true);
//     if (provider.onDownloadIsLoading) {
//       return const SizedBox(
//         width: 25.0,
//         height: 25.0,
//         child: CustomLoadingIndicator(
//           color: secondaryColor,
//         ),
//       );
//     } else {
//       if (provider.isDownloaded) {
//         return const Icon(
//           Icons.done,
//           size: 30,
//           color: secondaryColor,
//         );
//       } else {
//         return const Icon(
//           Icons.download,
//           size: 30,
//           color: secondaryColor,
//         );
//       }
//     }
//   }

//   void _zoomInOut() {
//     final Offset tapPosition = _doubleTapDownDetails!.localPosition;
//     final double zoomScale =
//         widget.fullScreenDoubleTapZoomScale ?? widget.maxScale;

//     final double x = -tapPosition.dx * (zoomScale - 1);
//     final double y = -tapPosition.dy * (zoomScale - 1);

//     final Matrix4 zoomedMatrix = Matrix4.identity()
//       ..translate(x, y)
//       ..scale(zoomScale);

//     final Matrix4 widgetMatrix = _transformationController.value.isIdentity()
//         ? zoomedMatrix
//         : Matrix4.identity();

//     _animation = Matrix4Tween(
//       begin: _transformationController.value,
//       end: widgetMatrix,
//     ).animate(
//       CurveTween(curve: Curves.easeOut).animate(_animationController),
//     );

//     _animationController.forward(from: 0);
//     _currentScale = _transformationController.value.isIdentity()
//         ? zoomScale
//         : widget.minScale;
//   }

//   void _onInteractionStart(ScaleStartDetails details) {
//     _animationDuration = Duration.zero;
//     _opacityDuration = Duration.zero;
//   }

//   void _onInteractionEnd(ScaleEndDetails details) async {
//     _currentScale = _transformationController.value.getMaxScaleOnAxis();
//     setState(() {
//       _animationDuration = const Duration(milliseconds: 300);
//     });
//     if (_imagePosition > closingTreshold) {
//       setState(() {
//         _imagePosition = MediaQuery.of(context).size.height; // move image down
//       });
//       Navigator.of(context).pop();
//     } else {
//       setState(() {
//         _imagePosition = 0;
//         _opacity = 1;
//         _opacityDuration = const Duration(milliseconds: 300);
//       });
//     }
//   }

//   void _onInteractionUpdate(ScaleUpdateDetails details) async {
//     // chose 1.05 because maybe the image was not fully zoomed back but it almost looks like that
//     if (details.pointerCount == 1 && _currentScale <= 1.05) {
//       setState(() {
//         _imagePosition += details.focalPointDelta.dy;
//         _opacity =
//             (1 - (_imagePosition / closingTreshold)).clamp(0, 1).toDouble();
//       });
//     }
//   }
// }
