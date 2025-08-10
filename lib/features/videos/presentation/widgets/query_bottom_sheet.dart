import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/presentation/provider/source_provider.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';
import '../../../../data/models/content_source.dart';
import '../../../../shared/widgets/misc/text_widget.dart';

class QueryBottomsheet extends StatefulWidget {
  final ContentSource source;
  final VoidCallback? onClose;
  final Function(String)? onSelected;

  const QueryBottomsheet({
    super.key,
    required this.source,
    this.onClose,
    this.onSelected,
  });

  @override
  State<QueryBottomsheet> createState() => _QueryBottomsheetState();
}

class _QueryBottomsheetState extends State<QueryBottomsheet>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _selectionController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Enhanced item animations
  final Map<String, AnimationController> _itemControllers = {};
  final Map<String, Animation<double>> _itemScales = {};
  final Map<String, Animation<double>> _itemSlides = {};
  final Map<String, Animation<double>> _itemGlows = {};

  @override
  void initState() {
    super.initState();
    _setupMainAnimations();
    _setupItemAnimations();
    _mainController.forward();
  }

  void _setupMainAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutBack,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _setupItemAnimations() {
    for (var key in widget.source.query.keys) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _itemControllers[key] = controller;

      _itemScales[key] = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _itemSlides[key] = Tween<double>(begin: 0, end: 4).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _itemGlows[key] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _selectionController.dispose();
    _buttonController.dispose();
    for (var controller in _itemControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleSelection(String key, String value) {
    var provider = context.read<SourceProvider>();

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      if (provider.selectedQuery == value) {
        provider.selectedQuery = null;
        _itemControllers[key]?.reverse();
        _selectionController.reverse();
      } else {
        // Reverse previous selection
        final currentSelected = widget.source.query.entries
            .where((entry) => entry.value == provider.selectedQuery)
            .map((entry) => entry.key)
            .firstOrNull;

        if (currentSelected != null) {
          _itemControllers[currentSelected]?.reverse();
        }

        provider.selectedQuery = value;
        _itemControllers[key]?.forward();
        _selectionController.forward();
      }
      provider.updateState();
    });
  }

  void _handleApply() {
    var provider = context.read<SourceProvider>();

    if (provider.selectedQuery != null) {
      _buttonController.forward().then((_) => _buttonController.reverse());
      HapticFeedback.mediumImpact();
      widget.onSelected!(provider.selectedQuery!);
      NH.navigateBack();
    }
  }

  void _handleClear() {
    var provider = context.read<SourceProvider>();
    HapticFeedback.lightImpact();

    provider.selectedQuery = null;
    provider.updateState();

    for (var controller in _itemControllers.values) {
      controller.reverse();
    }
    _selectionController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.scaffoldBackgroundColor.withOpacity(0.98),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEnhancedHeader(theme),
                    _buildEnhancedDivider(theme),
                    Flexible(
                      child: _buildCategoriesList(theme, isDark),
                    ),
                    _buildEnhancedBottomActions(theme, isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        children: [
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              // Enhanced icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.15),
                      AppColors.primaryColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: "Browse Categories",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text:
                          "${widget.source.query.length} categories available",
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),

              // Enhanced close button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[600],
                  ),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDivider(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.primaryColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      shrinkWrap: true,
      itemCount: widget.source.query.length,
      itemBuilder: (context, index) {
        final entry = widget.source.query.entries.elementAt(index);
        return _buildEnhancedCategoryItem(
            entry.key, entry.value, index, theme, isDark);
      },
    );
  }

  Widget _buildEnhancedCategoryItem(
      String key, String value, int index, ThemeData theme, bool isDark) {
    var selectedQuery = context.watch<SourceProvider>().selectedQuery;
    final isSelected = selectedQuery == value;
    final itemScale = _itemScales[key] ?? const AlwaysStoppedAnimation(1.0);
    final itemSlide = _itemSlides[key] ?? const AlwaysStoppedAnimation(0.0);
    final itemGlow = _itemGlows[key] ?? const AlwaysStoppedAnimation(0.0);

    return AnimatedBuilder(
      animation: Listenable.merge([itemScale, itemSlide, itemGlow]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(itemSlide.value, 0),
          child: Transform.scale(
            scale: itemScale.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor
                              .withOpacity(0.2 * itemGlow.value),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _toggleSelection(key, value),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: AppColors.primaryColor.withOpacity(0.1),
                  highlightColor: AppColors.primaryColor.withOpacity(0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppColors.primaryColor.withOpacity(0.08),
                                AppColors.primaryColor.withOpacity(0.04),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.4)
                            : (isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.2)),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildEnhancedSelectionIndicator(isSelected),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: key,
                                fontSize: 16.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : theme.textTheme.bodyLarge?.color,
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 12,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Selected',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSelectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
              )
            : null,
        color: isSelected ? null : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.primaryColor.withOpacity(0.3),
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Icons.check_rounded,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEnhancedBottomActions(ThemeData theme, bool isDark) {
    var selectedQuery = context.watch<SourceProvider>().selectedQuery;
    final hasSelection = selectedQuery != null && selectedQuery.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor.withOpacity(0.8),
            theme.scaffoldBackgroundColor,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Enhanced clear button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextButton.icon(
                onPressed: hasSelection ? _handleClear : null,
                icon: Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: hasSelection ? Colors.grey[600] : Colors.grey[400],
                ),
                label: TextWidget(
                  text: 'Clear Selection',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: hasSelection ? Colors.grey[600] : Colors.grey[400],
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Enhanced apply button
          Expanded(
            flex: hasSelection ? 2 : 1,
            child: AnimatedBuilder(
              animation: _buttonController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 - (_buttonController.value * 0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: hasSelection
                          ? LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: hasSelection ? null : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: hasSelection
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: hasSelection ? _handleApply : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasSelection
                                    ? Icons.check_circle_rounded
                                    : Icons.check_circle_outline,
                                size: 18,
                                color: hasSelection
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                              const SizedBox(width: 8),
                              TextWidget(
                                text: 'Apply Selection',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: hasSelection
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
