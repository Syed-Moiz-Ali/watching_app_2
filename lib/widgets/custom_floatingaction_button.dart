// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';

import '../core/global/app_global.dart';
import '../models/content_source.dart';
import '../screens/videos_list/components/query_bottomsheet.dart';

class CustomFloatingActionButton extends StatefulWidget {
  final ContentSource source;
  final Function(String)? onSelected;

  const CustomFloatingActionButton(
      {super.key, required this.source, required this.onSelected});

  @override
  _CustomFloatingActionButtonState createState() =>
      _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState
    extends State<CustomFloatingActionButton> {
  // Function to trigger the FAB press animation

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
            context: SMA.navigationKey.currentContext!,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return QueryBottomsheet(
                source: widget.source,
                onSelected: widget.onSelected,
              );
            });
      },
      backgroundColor: AppColors.primaryColor,
      child: const Icon(
        Icons.menu,
        size: 28,
        color: AppColors.backgroundColorLight,
      ),
    );
  }
}
