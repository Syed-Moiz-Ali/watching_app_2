import 'package:flutter/material.dart';
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
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  // String? _selectedItem;

  // Track item animations separately
  final Map<String, AnimationController> _itemControllers = {};
  final Map<String, Animation<double>> _itemScales = {};
  final Map<String, Animation<double>> _itemSlides = {};

  @override
  void initState() {
    super.initState();
    _setupMainAnimations();
    _setupItemAnimations();

    // Start entry animation
    _mainController.forward();
  }

  void _setupMainAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _setupItemAnimations() {
    // Create individual animations for each item
    for (var key in widget.source.query.keys) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );

      _itemControllers[key] = controller;
      _itemScales[key] = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );
      _itemSlides[key] = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _selectionController.dispose();
    for (var controller in _itemControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleSelection(String key, String value) {
    var provider = context.read<SourceProvider>();

    setState(() {
      if (provider.selectedQuery == value) {
        provider.selectedQuery = null;
        _itemControllers[key]?.reverse();
        _selectionController.reverse();
      } else {
        // Reverse previous selection if any
        if (provider.selectedQuery == value) {
          _itemControllers[provider.selectedQuery]?.reverse();
        }
        provider.selectedQuery = value;
        _itemControllers[key]?.forward();
        _selectionController.forward();
      }
      provider.updateState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildDivider(),
                  Flexible(
                    child: _buildCategoriesList(),
                  ),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: "Browse Categories",
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.3),
            AppColors.primaryColor.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shrinkWrap: true,
      itemCount: widget.source.query.length,
      itemBuilder: (context, index) {
        final entry = widget.source.query.entries.elementAt(index);
        return _buildCategoryItem(entry.key, entry.value, index);
      },
    );
  }

  Widget _buildCategoryItem(String key, String value, int index) {
    var selectedQuery = context.watch<SourceProvider>().selectedQuery;
    final isSelected = selectedQuery == value;
    final itemScale = _itemScales[key] ?? const AlwaysStoppedAnimation(1.0);
    final itemSlide = _itemSlides[key] ?? const AlwaysStoppedAnimation(0.0);

    return AnimatedBuilder(
      animation: Listenable.merge([itemScale, itemSlide]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(itemSlide.value, 0),
          child: Transform.scale(
            scale: itemScale.value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _toggleSelection(key, value),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryColor.withOpacity(0.0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.primaryColor.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    // boxShadow: isSelected
                    //     ? [
                    //         BoxShadow(
                    //           color: AppColors.primaryColor.withOpacity(0.2),
                    //           blurRadius: 8,
                    //           offset: const Offset(0, 4),
                    //         ),
                    //       ]
                    //     : null,
                  ),
                  child: Row(
                    children: [
                      _buildSelectionIndicator(isSelected),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextWidget(
                          text: key,
                          fontSize: 17.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey[800],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check,
                          color: AppColors.primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppColors.primaryColor
            : AppColors.primaryColor.withOpacity(0.1),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 1.0 : 0.0,
          child: const Icon(
            Icons.check,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                var provider = context.read<SourceProvider>();
                provider.selectedQuery = '';
                provider.updateState();
                for (var controller in _itemControllers.values) {
                  controller.reverse();
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const TextWidget(text: 'Clear Selection'),
            ),
          ),
          const SizedBox(width: 16),
          // Expanded(
          //   child: FilledButton(
          //     onPressed: _selectedItem != null ? () {} : null,
          //     style: FilledButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //       backgroundColor: AppColors.primaryColor,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),
          //     child: const Text('Apply'),
          //   ),
          // ),
          PrimaryButton(
            onTap: () {
              var provider = context.read<SourceProvider>();

              if (provider.selectedQuery != null) {
                widget.onSelected!(provider.selectedQuery!);
                NH.navigateBack();
              }
            },
            text: 'Apply',
            width: .45,
            borderRadius: 4.w,
          )
        ],
      ),
    );
  }
}
