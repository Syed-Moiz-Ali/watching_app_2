import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/constants/manga_detail_constants.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';

class GenreChip extends StatelessWidget {
  final String genre;

  const GenreChip({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MangaDetailConstants.chipPadding,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextWidget(
        text: genre,
        color: Colors.grey,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
