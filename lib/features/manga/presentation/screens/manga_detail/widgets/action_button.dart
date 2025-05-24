import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/constants/manga_detail_constants.dart';

import '../../../../../../shared/widgets/misc/text_widget.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: MangaDetailConstants.buttonHeight,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon,
              color: isPrimary ? Colors.white : Colors.black87, size: 18),
          label: TextWidget(
            text: label,
            color: isPrimary ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          style: TextButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
