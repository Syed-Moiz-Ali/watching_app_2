import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../loading/loading_indicator.dart';

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

  Future<void> getRandomErrorImage() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/stars2.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final random = Random();
      final randomImage = jsonData[random.nextInt(jsonData.length)];

      setState(() {
        randomErrorImage = randomImage['image'];
      });
    } catch (e) {
      // Silently ignore errors
    }
  }

  @override
  void initState() {
    super.initState();
    getRandomErrorImage();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSvg = widget.imagePath.toLowerCase().endsWith('.svg');
    final String image = widget.imagePath;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ClipRRect(
        borderRadius: widget.borderRadius is double
            ? BorderRadius.circular(widget.borderRadius)
            : (widget.borderRadius as BorderRadius? ??
                BorderRadius.circular(8)),
        child: _buildImage(image, isSvg),
      ),
    );
  }

  Widget _buildImage(String imageUrl, bool isSvg) {
    // Early validation: if the URL is empty or invalid, show error widget
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return _buildErrorWidget(); // Invalid URL (no host or scheme)
    }

    // For valid URLs, attempt to load the image
    return isSvg ? _buildSvgImage(imageUrl) : _buildRasterImage(imageUrl);
  }

  Widget _buildSvgImage(String imageUrl) {
    try {
      return SvgPicture.network(
        imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        placeholderBuilder: (context) => _buildPlaceholder(),
        semanticsLabel: 'SVG Image',
      );
    } catch (e) {
      // Catch any loading errors and return the error widget silently
      return _buildErrorWidget();
    }
  }

  Widget _buildRasterImage(String imageUrl) {
    try {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        placeholderFadeInDuration: const Duration(milliseconds: 700),
        useOldImageOnUrlChange: true,
      );
    } catch (e) {
      // Catch any loading errors and return the error widget silently
      return _buildErrorWidget();
    }
  }

  Widget _buildPlaceholder() {
    if (widget.height == null && widget.width == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const Center(child: CustomLoadingIndicator()),
      );
    }
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}
