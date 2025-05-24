import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/manga_reader_screen.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/constants/manga_detail_constants.dart';

import '../../../../../../shared/widgets/misc/text_widget.dart';

class ChapterTile extends StatelessWidget {
  final ContentItem item;
  final ContentItem details;
  final int index;

  const ChapterTile({
    super.key,
    required this.item,
    required this.details,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final chapter = details.detailContent!.chapter![index];

    return Container(
      margin: const EdgeInsets.only(bottom: MangaDetailConstants.listSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: MangaDetailConstants.tilePadding,
        // leading: Container(
        //   width: 40,
        //   height: 40,
        //   decoration: BoxDecoration(
        //     color: Colors.grey[100],
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: Center(
        //     child: TextWidget(
        //       text: '${details.detailContent!.chapter!.length - index}',
        //       fontWeight: FontWeight.bold,
        //       fontSize: 14.sp,
        //     ),
        //   ),
        // ),
        title: TextWidget(
          text: chapter.chapterName!,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        // subtitle: TextWidget(
        //   text: index < 3 ? 'New' : '$index days ago',
        //   fontWeight: FontWeight.bold,
        //   fontSize: 14,
        // ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
          size: 20,
        ),
        onTap: () {
          NH.navigateTo(MangaReaderScreen(item: item, chapter: chapter));
        },
      ),
    );
  }
}
