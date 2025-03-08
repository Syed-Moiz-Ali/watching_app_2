import 'package:flutter/material.dart';

import '../../../core/global/globals.dart';

class CustomPadding extends StatelessWidget {
  const CustomPadding({
    super.key,
    required this.child,
    this.allSidesFactor,
    this.horizontalFactor,
    this.verticalFactor,
    this.topFactor,
    this.bottomFactor,
    this.leftFactor,
    this.rightFactor,
  });

  final double? allSidesFactor; // Padding for all sides equally
  final double? bottomFactor; // Padding for bottom
  final Widget child;
  final double? horizontalFactor; // Padding for left and right
  final double? leftFactor; // Padding for left
  final double? rightFactor; // Padding for right
  final double? topFactor; // Padding for top
  final double? verticalFactor; // Padding for top and bottom

  @override
  Widget build(BuildContext context) {
    // Ensure that at least one of the padding factors is provided
    if (allSidesFactor == null &&
        horizontalFactor == null &&
        verticalFactor == null &&
        topFactor == null &&
        bottomFactor == null &&
        leftFactor == null &&
        rightFactor == null) {
      throw ArgumentError(
        'At least one padding factor must be provided.',
      );
    }

    // Validate padding combinations based on the provided rules
    if (allSidesFactor != null) {
      if (horizontalFactor != null ||
          verticalFactor != null ||
          topFactor != null ||
          bottomFactor != null ||
          leftFactor != null ||
          rightFactor != null) {
        throw ArgumentError(
          'You cannot provide both allSidesFactor and specific side factors at the same time.',
        );
      }
    }

    if (verticalFactor != null) {
      if (topFactor != null || bottomFactor != null || allSidesFactor != null) {
        throw ArgumentError(
          'If verticalFactor is provided, you cannot provide horizontal or side-specific padding factors.',
        );
      }
    }

    if (horizontalFactor != null) {
      if (leftFactor != null || rightFactor != null || allSidesFactor != null) {
        throw ArgumentError(
          'If horizontalFactor is provided, you cannot provide other padding factors.',
        );
      }
    }

    // Calculate padding for each side based on the provided factors
    final double leftPadding =
        leftFactor ?? horizontalFactor ?? allSidesFactor ?? 0.0;
    final double rightPadding =
        rightFactor ?? horizontalFactor ?? allSidesFactor ?? 0.0;
    final double topPadding =
        topFactor ?? verticalFactor ?? allSidesFactor ?? 0.0;
    final double bottomPadding =
        bottomFactor ?? verticalFactor ?? allSidesFactor ?? 0.0;

    // Apply padding
    return Padding(
      padding: EdgeInsets.only(
        left: SMA.size.width * leftPadding,
        right: SMA.size.width * rightPadding,
        top: SMA.size.height * topPadding,
        bottom: SMA.size.height * bottomPadding,
      ),
      child: Builder(
        builder: (context) {
          return child; // Replace with the widget you want to wrap
        },
      ),
    );
  }
}
