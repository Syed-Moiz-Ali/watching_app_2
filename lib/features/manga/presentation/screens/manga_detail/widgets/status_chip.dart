import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/constants/manga_detail_constants.dart';

import '../../../../../../shared/widgets/misc/text_widget.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isOngoing = status.toLowerCase().contains('ongoing');
    return Container(
      padding: MangaDetailConstants.chipPadding,
      decoration: BoxDecoration(
        color: isOngoing
            ? Colors.green.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOngoing
              ? Colors.green.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOngoing ? Colors.green : Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          TextWidget(
            text: status,
            color: isOngoing ? Colors.green : Colors.blue,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
