// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';
import '../../../data/database/local_database.dart';

class MinimalistFiltersBottomSheet extends StatefulWidget {
  final String contentType;
  final List<ContentItem> items;
  final Function(List<ContentItem>) onFiltersApplied;

  const MinimalistFiltersBottomSheet({
    super.key,
    required this.contentType,
    required this.items,
    required this.onFiltersApplied,
  });

  static void show(
    BuildContext context, {
    required String contentType,
    required List<ContentItem> items,
    required Function(List<ContentItem>) onFiltersApplied,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MinimalistFiltersBottomSheet(
        contentType: contentType,
        items: items,
        onFiltersApplied: onFiltersApplied,
      ),
    );
  }

  @override
  State<MinimalistFiltersBottomSheet> createState() =>
      _MinimalistFiltersBottomSheetState();
}

class _MinimalistFiltersBottomSheetState
    extends State<MinimalistFiltersBottomSheet> {
  int _currentSection = 0;

  // Filter states
  String _sortOption = 'Latest';
  final List<String> _selectedSources = [];
  DateTimeRange? _dateRange;
  final Map<String, bool> _additionalFilters = {
    'Watched': false,
    'Unwatched': false,
    'HD Only': false,
  };

  // Get unique sources from items
  List<String> get _availableSources {
    final Set<String> sources = {};
    for (var item in widget.items) {
      if (item.source.name.isNotEmpty) {
        sources.add(item.source.name);
      }
    }
    return sources.toList();
  }

  List<ContentItem> _applyFilters() {
    List<ContentItem> filteredItems = List.from(widget.items);

    // Apply sort
    switch (_sortOption) {
      case 'Latest':
        filteredItems.sort((a, b) => (b.addedAt).compareTo(a.addedAt));
        break;
      case 'Oldest':
        filteredItems.sort((a, b) => (a.addedAt).compareTo(b.addedAt));
        break;
      case 'A-Z':
        filteredItems.sort((a, b) => (a.title).compareTo(b.title));
        break;
      case 'Z-A':
        filteredItems.sort((a, b) => (b.title).compareTo(a.title));
        break;
    }

    // Apply source filter
    if (_selectedSources.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => _selectedSources.contains(item.source.name))
          .toList();
    }

    // Apply date filter
    if (_dateRange != null) {
      filteredItems = filteredItems
          .where((item) =>
              item.addedAt.isAfter(_dateRange!.start) &&
              item.addedAt
                  .isBefore(_dateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    // Apply additional filters
    if (_additionalFilters['HD Only'] == true) {
      filteredItems = filteredItems
          .where((item) =>
              item.quality == 'HD' ||
              item.quality == '1080p' ||
              item.quality == '4K')
          .toList();
    }

    return filteredItems;
  }

  void _resetFilters() {
    setState(() {
      _sortOption = 'Latest';
      _selectedSources.clear();
      _dateRange = null;
      _additionalFilters.forEach((key, value) {
        _additionalFilters[key] = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Elegant header
              _buildHeader(),

              // Minimalist navigation
              _buildNavigation(),

              // Content area
              Expanded(
                child: _buildContent(scrollController),
              ),

              // Clean action bar
              _buildActionBar(),
            ],
          ),
        )
            .animate()
            .slideY(
              begin: 1,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 2.h, bottom: 3.h),
      child: Column(
        children: [
          // Subtle handle
          Container(
            width: 12.w,
            height: 0.4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ).animate().fadeIn(delay: 200.ms).scaleX(begin: 0.5, end: 1.0),

          SizedBox(height: 3.h),

          // Clean title with close button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'Filters',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w300,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3, end: 0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 6.w,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ).animate().fadeIn(delay: 400.ms).then().shimmer(
                    duration: 1500.ms, color: Colors.white.withOpacity(0.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final sections = [
      {'title': 'Sort', 'icon': Icons.sort_rounded},
      {'title': 'Source', 'icon': Icons.source_outlined},
      {'title': 'Date', 'icon': Icons.calendar_today_outlined},
      // {'title': 'More', 'icon': Icons.tune_rounded},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.all(0.5.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          final isActive = _currentSection == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentSection = index;
                });
              },
              child: AnimatedContainer(
                duration: 300.ms,
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      section['icon'] as IconData,
                      size: 5.w,
                      color: isActive ? AppColors.primaryColor : Colors.grey,
                    ),
                    if (isActive) ...[
                      SizedBox(width: 2.w),
                      TextWidget(
                        text: section['title'] as String,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      )
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideX(begin: 0.3, end: 0),
                    ]
                  ],
                ),
              ),
            ),
          ).animate(target: isActive ? 1 : 0);
        }).toList(),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildContent(ScrollController scrollController) {
    switch (_currentSection) {
      case 0:
        return _buildSortSection(scrollController);
      case 1:
        return _buildSourceSection(scrollController);
      case 2:
        return _buildDateSection(scrollController);
      // case 3:
      //   return _buildMoreSection(scrollController);
      default:
        return Container();
    }
  }

  Widget _buildSortSection(ScrollController scrollController) {
    final sortOptions = ['Latest', 'Oldest', 'A-Z', 'Z-A'];

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      children: [
        TextWidget(
          text: 'Sort your content',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: Colors.grey[600],
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 3.h),
        ...sortOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _sortOption == option;

          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _sortOption = option;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 4.w,
                              )
                            : null,
                      ),
                      SizedBox(width: 4.w),
                      TextWidget(
                        text: option,
                        fontSize: 15.sp,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected ? AppColors.primaryColor : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (300 + index * 100).ms)
              .slideX(begin: 0.3, end: 0, delay: (300 + index * 100).ms);
        }),
      ],
    );
  }

  Widget _buildSourceSection(ScrollController scrollController) {
    final sources = _availableSources;

    if (sources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.source_outlined,
                size: 12.w,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 3.h),
            TextWidget(
              text: 'No sources available',
              fontSize: 16.sp,
              color: Colors.grey[600],
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: 'Choose sources',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedSources.length == sources.length) {
                    _selectedSources.clear();
                  } else {
                    _selectedSources.clear();
                    _selectedSources.addAll(sources);
                  }
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
              child: TextWidget(
                text: _selectedSources.length == sources.length
                    ? 'Clear all'
                    : 'Select all',
                fontSize: 14.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 3.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 2.h,
          children: sources.asMap().entries.map((entry) {
            final index = entry.key;
            final source = entry.value;
            final isSelected = _selectedSources.contains(source);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSources.remove(source);
                  } else {
                    _selectedSources.add(source);
                  }
                });
              },
              child: AnimatedContainer(
                duration: 200.ms,
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: TextWidget(
                  text: source,
                  fontSize: 14.sp,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ).animate().fadeIn(delay: (300 + index * 80).ms).then().shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.3),
                  delay: (1000 + index * 200).ms,
                );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSection(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      children: [
        TextWidget(
          text: 'Filter by date',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: Colors.grey[600],
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 4.h),

        // Date range display
        GestureDetector(
          onTap: _selectDateRange,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _dateRange != null
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.date_range_rounded,
                        color: AppColors.primaryColor,
                        size: 6.w,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Date Range',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 0.5.h),
                          TextWidget(
                            text: _dateRange != null
                                ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                                : 'Tap to select dates',
                            fontSize: 13.sp,
                            color: _dateRange != null
                                ? AppColors.primaryColor
                                : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                    if (_dateRange != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _dateRange = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 4.w,
                            color: Colors.grey[600],
                          ),
                        ),
                      ).animate().fadeIn(
                            delay: 200.ms,
                            duration: 300.ms,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),

        SizedBox(height: 4.h),

        // Quick filters
        TextWidget(
          text: 'Quick select',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 2.h),

        Wrap(
          spacing: 3.w,
          runSpacing: 2.h,
          children: [
            _buildQuickDateChip('Today', 0),
            _buildQuickDateChip('Yesterday', 1),
            _buildQuickDateChip('Last 7 days', 7),
            _buildQuickDateChip('Last 30 days', 30),
            _buildQuickDateChip('This month', -1),
          ],
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildQuickDateChip(String label, int days) {
    return GestureDetector(
      onTap: () => _applyQuickDateFilter(days),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: TextWidget(
          text: label,
          fontSize: 13.sp,
          color: Colors.grey[700],
        ),
      ),
    ).animate().fadeIn(
        delay: (500 +
                [
                      'Today',
                      'Yesterday',
                      'Last 7 days',
                      'Last 30 days',
                      'This month'
                    ].indexOf(label) *
                    100)
            .ms);
  }

  // Widget _buildMoreSection(ScrollController scrollController) {
  //   return ListView(
  //     controller: scrollController,
  //     padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
  //     children: [
  //       TextWidget(
  //         text: 'Additional options',
  //         fontSize: 16.sp,
  //         fontWeight: FontWeight.w400,
  //         color: Colors.grey[600],
  //       ).animate().fadeIn(delay: 200.ms),

  //       SizedBox(height: 3.h),

  //       ..._additionalFilters.entries.map((mapEntry) {
  //         final index = mapEntry.key;
  //         final entry = mapEntry.value;

  //         return Container(
  //           margin: EdgeInsets.only(bottom: 2.h),
  //           decoration: BoxDecoration(
  //             color: Colors.grey.withOpacity(0.03),
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: SwitchListTile(
  //             title: TextWidget(
  //               text: entry,
  //               fontSize: 15.sp,
  //               fontWeight: FontWeight.w400,
  //             ),
  //             value: entry.value,
  //             activeColor: AppColors.primaryColor,
  //             contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             onChanged: (value) {
  //               setState(() {
  //                 _additionalFilters[entry.key] = value;

  //                 // Handle mutually exclusive filters
  //                 if (entry.key == 'Watched' && value) {
  //                   _additionalFilters['Unwatched'] = false;
  //                 } else if (entry.key == 'Unwatched' && value) {
  //                   _additionalFilters['Watched'] = false;
  //                 }
  //               });
  //             },
  //           ),
  //         ).animate()
  //           .fadeIn(delay: (300 + index * 150).ms)
  //           .slideX(begin: 0.3, end: 0, delay: (300 + index * 150).ms);
  //       }),
  //     ],
  //   );
  // }

  Widget _buildActionBar() {
    final hasActiveFilters = _sortOption != 'Latest' ||
        _selectedSources.isNotEmpty ||
        _dateRange != null ||
        _additionalFilters.values.any((value) => value);

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (hasActiveFilters)
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(right: 3.w),
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextWidget(
                    text: 'Reset',
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              width: 1.0,
              borderRadius: 16,
              onTap: () {
                widget.onFiltersApplied(_applyFilters());
                Navigator.pop(context);
              },
              child: TextWidget(
                text: 'Apply Filters',
                fontSize: 15.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideX(begin: 0.3, end: 0)
              .then()
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _applyQuickDateFilter(int days) {
    final now = DateTime.now();
    DateTimeRange range;

    if (days > 0) {
      range = DateTimeRange(
        start: now.subtract(Duration(days: days)),
        end: now,
      );
    } else if (days == 0) {
      range = DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: now,
      );
    } else if (days == -1) {
      range = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      );
    } else {
      return;
    }

    setState(() {
      _dateRange = range;
    });
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final initialDateRange = _dateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _dateRange = newDateRange;
      });
    }
  }
}
