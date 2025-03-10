// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';

import '../../../data/database/local_database.dart';

class FiltersBottomSheet extends StatefulWidget {
  final String contentType;
  final List<ContentItem> items;
  final Function(List<ContentItem>) onFiltersApplied;

  const FiltersBottomSheet({
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
      builder: (context) => FiltersBottomSheet(
        contentType: contentType,
        items: items,
        onFiltersApplied: onFiltersApplied,
      ),
    );
  }

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['Sort', 'Source', 'Date', 'More'];

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      // case 'Popular':
      //   filteredItems.sort((a, b) => (b.views ?? 0).compareTo(a.viewCount ?? 0));
      //   break;
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

    // // Apply additional filters
    // if (_additionalFilters['Watched'] == true) {
    //   filteredItems = filteredItems.where((item) => item.watched == true).toList();
    // }

    // if (_additionalFilters['Unwatched'] == true) {
    //   filteredItems = filteredItems.where((item) => item.watched != true).toList();
    // }

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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle and header
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Column(
                  children: [
                    Container(
                      width: 15.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: TextWidget(
                            text: 'Filter and Sort',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ).animate().scale(
                                duration: const Duration(milliseconds: 200),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: _tabTitles
                        .map((title) => Tab(
                              child: TextWidget(
                                text: title,
                                fontSize: 14.sp,
                              ),
                            ))
                        .toList(),
                    indicatorWeight: 1,
                    // indicator: BoxDecoration(
                    //   color: AppColors.primaryColor,
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Theme.of(context).textTheme.bodyLarge?.color,
                    onTap: (index) {
                      // Optional haptic feedback
                      // HapticFeedback.lightImpact();
                    },
                    splashBorderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Sort tab
                    _buildSortTab(scrollController),

                    // Source tab
                    _buildSourceTab(scrollController),

                    // Date tab
                    _buildDateTab(scrollController),

                    // More filters tab
                    _buildMoreFiltersTab(scrollController),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _sortOption = 'Latest';
                          _selectedSources.clear();
                          _dateRange = null;
                          _additionalFilters.forEach((key, value) {
                            _additionalFilters[key] = false;
                          });
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.primaryColor),
                      ),
                      child: TextWidget(
                        text: 'Reset',
                        fontSize: 14.sp,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 400)),
                    PrimaryButton(
                      width: 0.4,
                      borderRadius: 12,
                      onTap: () {
                        // Apply all filters and close
                        widget.onFiltersApplied(_applyFilters());
                        Navigator.pop(context);
                      },
                      child: TextWidget(
                        text: 'Apply',
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 400))
                        .scaleXY(
                          begin: 0.95,
                          end: 1,
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 200),
                        ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .slideY(
              begin: 1,
              end: 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
            )
            .fadeIn(duration: const Duration(milliseconds: 300));
      },
    );
  }

  Widget _buildSortTab(ScrollController scrollController) {
    final sortOptions = ['Latest', 'Oldest', 'A-Z', 'Z-A', 'Popular'];
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      children: [
        TextWidget(
          text: 'Sort By',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 2.h),
        ...sortOptions.map((option) {
          bool isSelected = _sortOption == option;
          return ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: TextWidget(
              text: option,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            leading: Radio<String>(
              value: option,
              groupValue: _sortOption,
              activeColor: AppColors.primaryColor,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
              },
            ),
            selected: isSelected,
            selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
            onTap: () {
              setState(() {
                _sortOption = option;
              });
            },
          ).animate().fadeIn(
              delay: Duration(milliseconds: 100 * sortOptions.indexOf(option)));
        }),
      ],
    );
  }

  Widget _buildSourceTab(ScrollController scrollController) {
    final sources = _availableSources;
    if (sources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.source_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 2.h),
            TextWidget(
              text: 'No source information available',
              fontSize: 16.sp,
              color: Colors.grey,
            ),
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
              text: 'Filter by Source',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
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
              child: TextWidget(
                text: _selectedSources.length == sources.length
                    ? 'Unselect All'
                    : 'Select All',
                fontSize: 14.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: sources.map((source) {
            bool isSelected = _selectedSources.contains(source);
            return FilterChip(
              label: TextWidget(
                text: source,
                fontSize: 13.sp,
                color: isSelected ? Colors.white : null,
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              backgroundColor: Colors.grey.withOpacity(0.1),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isSelected ? AppColors.primaryColor : Colors.transparent,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSources.add(source);
                  } else {
                    _selectedSources.remove(source);
                  }
                });
              },
              elevation: isSelected ? 2 : 0,
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
            ).animate().fadeIn(
                delay: Duration(milliseconds: 50 * sources.indexOf(source)));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      children: [
        TextWidget(
          text: 'Filter by Date Added',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 3.h),

        // Date range selector
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _dateRange != null
                  ? AppColors.primaryColor
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: 'Selected Date Range',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 1.5.h, horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 5.w),
                          SizedBox(width: 2.w),
                          TextWidget(
                            text: _dateRange?.start != null
                                ? '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year}'
                                : 'Start Date',
                            fontSize: 13.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: TextWidget(
                      text: 'to',
                      fontSize: 14.sp,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 1.5.h, horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 5.w),
                          SizedBox(width: 2.w),
                          TextWidget(
                            text: _dateRange?.end != null
                                ? '${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}'
                                : 'End Date',
                            fontSize: 13.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_dateRange != null)
                    OutlinedButton.icon(
                      icon: Icon(Icons.clear, size: 5.w),
                      label: TextWidget(
                        text: 'Clear',
                        fontSize: 14.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _dateRange = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.5.h, horizontal: 4.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ElevatedButton.icon(
                    icon:
                        Icon(Icons.date_range, color: Colors.white, size: 5.w),
                    label: TextWidget(
                      text: 'Select Dates',
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                    onPressed: () async {
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
                                onSurface: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!,
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                          vertical: 1.5.h, horizontal: 4.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 100)).slideY(
            begin: 0.2, end: 0, delay: const Duration(milliseconds: 100)),

        SizedBox(height: 3.h),

        // Quick date filters
        TextWidget(
          text: 'Quick Filters',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            _buildQuickDateFilter('Today', 0),
            _buildQuickDateFilter('Yesterday', 1),
            _buildQuickDateFilter('Last 7 days', 7),
            _buildQuickDateFilter('Last 30 days', 30),
            _buildQuickDateFilter('This month', -1),
            _buildQuickDateFilter('Last month', -2),
          ],
        ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
      ],
    );
  }

  Widget _buildQuickDateFilter(String label, int days) {
    return InkWell(
      onTap: () {
        final now = DateTime.now();
        DateTimeRange range;

        if (days > 0) {
          // Simple day range
          range = DateTimeRange(
            start: now.subtract(Duration(days: days)),
            end: now,
          );
        } else if (days == 0) {
          // Today
          range = DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: now,
          );
        } else if (days == -1) {
          // This month
          range = DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          );
        } else {
          // Last month
          final lastMonth = now.month == 1
              ? DateTime(now.year - 1, 12, 1)
              : DateTime(now.year, now.month - 1, 1);

          final lastDay = DateTime(
            lastMonth.year,
            lastMonth.month + 1,
            0,
          ).day;

          range = DateTimeRange(
            start: lastMonth,
            end: DateTime(lastMonth.year, lastMonth.month, lastDay),
          );
        }

        setState(() {
          _dateRange = range;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextWidget(
          text: label,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  Widget _buildMoreFiltersTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      children: [
        TextWidget(
          text: 'Additional Filters',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 3.h),

        ..._additionalFilters.entries.map((entry) {
          return SwitchListTile(
            title: TextWidget(
              text: entry.key,
              fontSize: 14.sp,
            ),
            value: entry.value,
            activeColor: AppColors.primaryColor,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onChanged: (value) {
              setState(() {
                _additionalFilters[entry.key] = value;

                // Handle mutually exclusive filters
                if (entry.key == 'Watched' && value) {
                  _additionalFilters['Unwatched'] = false;
                } else if (entry.key == 'Unwatched' && value) {
                  _additionalFilters['Watched'] = false;
                }
              });
            },
          )
              .animate()
              .fadeIn(
                  delay: Duration(
                      milliseconds: 100 *
                          _additionalFilters.keys.toList().indexOf(entry.key)))
              .slideX(
                  begin: 0.2,
                  end: 0,
                  delay: Duration(
                      milliseconds: 100 *
                          _additionalFilters.keys.toList().indexOf(entry.key)));
        }),

        SizedBox(height: 3.h),

        // Content type specific filters based on widget.contentType
        if (widget.contentType == ContentTypes.VIDEO ||
            widget.contentType == ContentTypes.ANIME)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: 'Duration',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  _buildDurationFilter('Short (<5 min)'),
                  _buildDurationFilter('Medium (5-20 min)'),
                  _buildDurationFilter('Long (>20 min)'),
                ],
              ),
            ],
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
      ],
    );
  }

  Widget _buildDurationFilter(String label) {
    bool isSelected = false; // Connect to your state management

    return FilterChip(
      label: TextWidget(
        text: label,
        fontSize: 13.sp,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryColor,
      backgroundColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (selected) {
        // Connect to your state management
      },
    );
  }
}
