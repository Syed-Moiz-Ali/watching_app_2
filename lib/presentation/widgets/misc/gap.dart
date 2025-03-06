import 'package:flutter/material.dart';
import 'package:watching_app_2/core/global/globals.dart';

class CustomGap extends StatelessWidget {
  const CustomGap({
    super.key,
    this.heightFactor,
    this.widthFactor,
  });

  final double? heightFactor; // Renamed from 'heightPercentage'
  final double? widthFactor; // Renamed from 'widthPercentage'

  @override
  Widget build(BuildContext context) {
    // Check that exactly one of the widthFactor or heightFactor is provided
    if (widthFactor == null && heightFactor == null) {
      throw ArgumentError(
          'Either widthFactor or heightFactor must be provided, but not both.');
    }

    // If both are provided, throw an error (only one should be provided)
    if (widthFactor != null && heightFactor != null) {
      throw ArgumentError(
          'Both widthFactor and heightFactor are provided. Only one should be given.');
    }

    // Calculate the size based on the provided factor
    return SizedBox(
      width: widthFactor != null
          ? SMA.size.width * widthFactor! // Scale width based on the factor
          : null, // Use 0 if no widthFactor is provided
      height: heightFactor != null
          ? SMA.size.height * heightFactor! // Scale height based on the factor
          : null, // Use 0 if no heightFactor is provided
    );
  }
}
