import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/widgets/text_widget.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabChanged;

  const CustomTabBar({
    required this.tabController,
    required this.onTabChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Glowing background effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Main tab bar container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(.8),
                  AppColors.primaryColor.withOpacity(0.6),
                  AppColors.primaryColor.withOpacity(0.6),
                  AppColors.primaryColor.withOpacity(0.8),
                  // AppColors.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundColorDark.withOpacity(0.9),
                    AppColors.backgroundColorDark.withOpacity(0.7),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              labelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, size: 20),
                      SizedBox(width: 8),
                      TextWidget(
                        text: 'Videos',
                        color: AppColors.backgroundColorLight,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, size: 20),
                      SizedBox(width: 8),
                      TextWidget(
                        text: 'TikTok',
                        color: AppColors.backgroundColorLight,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 20),
                      SizedBox(width: 8),
                      TextWidget(
                        text: 'Photos',
                        color: AppColors.backgroundColorLight,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 20),
                      SizedBox(width: 8),
                      TextWidget(
                        text: 'Mangas',
                        color: AppColors.backgroundColorLight,
                      ),
                    ],
                  ),
                ),
              ],
              onTap: onTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}
