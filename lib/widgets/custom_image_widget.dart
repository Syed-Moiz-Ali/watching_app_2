import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';

import 'loading_indicator.dart';

class CustomImageWidget extends StatefulWidget {
  final String imagePath;
  final BoxFit fit;
  final double? height;
  final double? width;
  final dynamic borderRadius;

  const CustomImageWidget({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.fill,
    this.height = double.infinity,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  State<CustomImageWidget> createState() => _CustomImageWidgetState();
}

class _CustomImageWidgetState extends State<CustomImageWidget> {
  String? randomErrorImage;

  // Fetch the JSON data and return a random image
  Future<void> getRandomErrorImage() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/stars2.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    // Select a random image from the list
    final random = Random();
    final randomImage = jsonData[random.nextInt(jsonData.length)];

    setState(() {
      randomErrorImage = randomImage['image'];
    });
  }

  @override
  void initState() {
    super.initState();
    getRandomErrorImage();
  }

  @override
  Widget build(BuildContext context) {
    // bool isSvg = widget.imagePath.endsWith('.svg');
    final String image = widget.imagePath;

    // const String defaultErrorImage =
    //     'https://dicdn.bigfuck.tv/Qbc_5-9LHHJQijmVZSAKSkjuET8-WEVK52UdxGdxXGs/rs:fill:360:506/crop:0:0.90:no/enlarge:1/wm:1:nowe:0:0:1/wmu:aHR0cHM6Ly9jZG42OTY5NjE2NC5haGFjZG4ubWUvcG9ybnN0YXJfYXZhdGFyX3dhdGVybWFyay5wbmc=/aHR0cHM6Ly9pY2RuMDUuYmlnZnVjay50di9wb3Juc3Rhci84NDAvMTU2YTQ4NjlkMDhlZTBiODY0ZDlmMGEwNWY3MmE4ZWIuanBn.webp';
    // If random error image is not loaded, use the default error image
    // final String errorImage = randomErrorImage ?? defaultErrorImage;
    const String nonNSFWImage =
        "https://media.istockphoto.com/id/827247322/vector/danger-sign-vector-icon-attention-caution-illustration-business-concept-simple-flat-pictogram.jpg?s=612x612&w=0&k=20&c=BvyScQEVAM94DrdKVybDKc_s0FBxgYbu-Iv6u7yddbs=";

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child:
            // isSvg
            // ? SvgPicture.network(
            //     image,
            //     fit: widget.fit,
            //     placeholderBuilder: (context) =>
            //         (widget.height == null && widget.width == null)
            //             ? const Center(child: CustomLoadingIndicator())
            //             : Container(
            //                 color: greyColor.shade300,
            //                 height: widget.height,
            //                 width: widget.width,
            //               ),
            //   )
            // :
            CachedNetworkImage(
          imageUrl: image,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          placeholder: (context, url) =>
              (widget.height == null && widget.width == null)
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * .8,
                      child: const Center(child: CustomLoadingIndicator()))
                  : Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.grey,
                size: 32,
              ),
            ),
          ),
          // Stack(
          //   children: [
          //     Opacity(
          //       opacity: 0.5,
          //       child: CachedNetworkImage(
          //         imageUrl: nonNSFWImage,
          //         width: double.infinity,
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //     const Center(
          //       child: Icon(Icons.error),
          //     ),
          //   ],
          // ),
          placeholderFadeInDuration: const Duration(milliseconds: 700),
          useOldImageOnUrlChange: true,
        ),
      ),
    );
  }
}
