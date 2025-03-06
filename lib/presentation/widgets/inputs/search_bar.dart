import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import 'package:watching_app_2/core/constants/colors.dart';

class PremiumSearchBar extends StatefulWidget {
  final bool isShowSearchBar;
  final Function(String)? onSearch;
  final VoidCallback? onClose;

  const PremiumSearchBar({
    super.key,
    required this.isShowSearchBar,
    this.onSearch,
    this.onClose,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late Animation<Color?> _colorAnimation;
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.backgroundColorDark.withOpacity(0.1),
      end: AppColors.backgroundColorDark.withOpacity(0.2),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isShowSearchBar) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(PremiumSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShowSearchBar != oldWidget.isShowSearchBar) {
      if (widget.isShowSearchBar) {
        _animationController.forward();
        _focusNode.requestFocus();
      } else {
        _animationController.reverse();
        _focusNode.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w),
                    boxShadow: [
                      // BoxShadow(
                      //   color: AppColors.backgroundColorDark.withOpacity(0.1),
                      //   blurRadius: _blurAnimation.value,
                      //   spreadRadius: 2,
                      // ),
                      BoxShadow(
                        color: _colorAnimation.value ?? Colors.transparent,
                        blurRadius: _blurAnimation.value * .5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.w),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value,
                      ),
                      child: Container(
                        height: 6.5.h,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color:
                              AppColors.backgroundColorLight.withOpacity(0.9),
                          border: Border.all(
                            color:
                                AppColors.backgroundColorLight.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildSearchIcon(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(),
                            ),
                            // const SizedBox(width: 12),
                            // _buildClearButton(),
                          ],
                        ),
                      ),
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

  Widget _buildSearchIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: (1 - value) * 2 * 3.14,
          child: Opacity(
            opacity: value,
            child: Icon(
              Icons.search_rounded,
              color: AppColors.secondaryColor,
              size: 22.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      // onSubmitted: widget.onSearch,
      onEditingComplete: () {
        if (widget.onSearch != null) {
          widget.onSearch!(_searchController.text);
          _focusNode.unfocus();
          _searchController.clear();
        }
      },
      style: TextStyle(
        fontSize: 18,
        color: Colors.black.withOpacity(0.8),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Search...',
        hintStyle: TextStyle(
          fontSize: 18,
          color: Colors.black.withOpacity(0.3),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
