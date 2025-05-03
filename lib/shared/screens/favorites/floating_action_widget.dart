import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/content_item.dart';
import 'filters_bottom_sheet.dart'; // Assume this is your bottom sheet implementation

class FloatingActionButtonWidget extends StatefulWidget {
  final String contentType;
  final List<ContentItem> favorites; // Replace with your actual data type

  const FloatingActionButtonWidget({
    Key? key,
    required this.contentType,
    required this.favorites,
  }) : super(key: key);

  @override
  _FloatingActionButtonWidgetState createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget>
    with SingleTickerProviderStateMixin {
  List<dynamic> filteredFavorites = [];
  bool _filtersApplied = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    filteredFavorites = widget.favorites;

    // Initialize animation controller for subtle scale effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isHovered = true;
        });
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
        FiltersBottomSheet.show(
          context,
          contentType: widget.contentType,
          items: widget.favorites,
          onFiltersApplied: (filteredItems) {
            setState(() {
              filteredFavorites = filteredItems;
              _filtersApplied = true;
            });
          },
        );
      },
      onTapCancel: () {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26.w,
              height: 6.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isHovered
                      ? [
                          AppColors.primaryColor.withOpacity(0.9),
                          AppColors.secondaryColor.withOpacity(0.9)
                        ]
                      : [AppColors.primaryColor, AppColors.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.sp),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyColor.withOpacity(0.15),
                    blurRadius: 8.sp,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _filtersApplied ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.filter_list_rounded,
                      size: 20.sp,
                      color: AppColors.backgroundColorLight,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Filter',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.backgroundColorLight,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
