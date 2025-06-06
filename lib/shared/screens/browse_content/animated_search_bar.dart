import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/database/local_database.dart';

import '../../widgets/misc/text_widget.dart';

class UltraPremiumSearchBar extends StatefulWidget {
  const UltraPremiumSearchBar({
    super.key,
    required this.onSearch,
    required this.onCategoryChanged,
    required this.recentSearches,
    required this.onRecentSearchesUpdated,
    this.categories = ContentTypes.ALL_TYPES,
    this.hintText = 'Search your content...',
    this.primaryColor = const Color(0xFF6C5CE7),
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF2D3748),
    this.accentColor = const Color(0xFF6C5CE7),
    this.animationDuration = const Duration(milliseconds: 250),
  });

  final Color backgroundColor;
  final List<String> categories;
  final String hintText;
  final Function(String) onCategoryChanged;
  final Function(List<String>) onRecentSearchesUpdated;
  final Function(String, String) onSearch;
  final Color primaryColor;
  final List<String> recentSearches;
  final Color textColor;
  final Color accentColor;
  final Duration animationDuration;

  @override
  State<UltraPremiumSearchBar> createState() => _UltraPremiumSearchBarState();
}

class _UltraPremiumSearchBarState extends State<UltraPremiumSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearchFocused = false;
  String _selectedCategory = 'All';
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  late StreamSubscription<bool> keyboardSubscription;
  late AnimationController _animationController;
  late Animation<double> _borderRadiusAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _shadowOpacityAnimation;
  late Animation<double> _iconSizeAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_handleFocusChange);
    _selectedCategory = widget.categories.first;

    // Setup animations
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _borderRadiusAnimation = Tween<double>(begin: 24.0, end: 16.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _borderColorAnimation = ColorTween(
      begin: widget.textColor.withOpacity(0.15),
      end: widget.primaryColor,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _shadowOpacityAnimation = Tween<double>(begin: 0.05, end: 0.12).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _iconSizeAnimation = Tween<double>(begin: 22.0, end: 24.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    if (kDebugMode) {
      print(
          'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');
    }

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _removeDropdownOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
      if (_isSearchFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _hideDropdown();
      }
    });
  }

  void _showDropdown(BuildContext context) {
    _removeDropdownOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + size.height - 30,
        right: 16,
        width: 220,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1.0,
          curve: Curves.easeOutCubic,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            offset: const Offset(0, 0),
            curve: Curves.easeOutCubic,
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(16),
              shadowColor: widget.primaryColor.withOpacity(0.2),
              color: widget.backgroundColor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      // color: widget.backgroundColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.primaryColor.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: _buildDropdownContent(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _hideDropdown() {
    _removeDropdownOverlay();
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _removeDropdownOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDropdownContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(16),
        //   child: Row(
        //     children: [
        //       Icon(
        //         Icons.category_rounded,
        //         color: widget.primaryColor,
        //         size: 18,
        //       ),
        //       const SizedBox(width: 8),
        //       TextWidget(text:
        //         'Select Category',
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold,
        //           color: widget.textColor,
        //           fontSize: 14,
        //           letterSpacing: 0.3,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // const Divider(height: 1, thickness: 1.2),
        ...widget.categories.map((category) => _buildCategoryItem(category)),
      ],
    );
  }

  Widget _buildCategoryItem(String category) {
    final bool isSelected = category == _selectedCategory;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
          widget.onCategoryChanged(category);
          _hideDropdown();
        },
        splashColor: widget.primaryColor.withOpacity(0.1),
        highlightColor: widget.primaryColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? widget.primaryColor.withOpacity(0.08) : null,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.12),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? widget.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? widget.primaryColor
                        : widget.textColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: category,
                  color: isSelected ? widget.primaryColor : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
              border: Border.all(
                color: _isSearchFocused
                    ? _borderColorAnimation.value ??
                        widget.textColor.withOpacity(0.15)
                    : widget.primaryColor,
                width: _isSearchFocused ? 2.0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isSearchFocused
                      ? widget.primaryColor
                          .withOpacity(_shadowOpacityAnimation.value)
                      : Colors.black.withOpacity(_isHovering ? 0.08 : 0.05),
                  blurRadius: _isSearchFocused ? 12 : 8,
                  spreadRadius: _isSearchFocused ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildSearchContent(),
          ),
        );
      },
    );
  }

  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Icon(
                Icons.search_rounded,
                color: _isSearchFocused
                    ? widget.primaryColor
                    : widget.textColor.withOpacity(0.6),
                size: _iconSizeAnimation.value,
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              onEditingComplete: () {
                widget.onSearch(_searchController.text, _selectedCategory);
                // _addToRecentSearches(_searchController.text);
                _searchFocusNode.unfocus();
              },
              onChanged: (_) {
                setState(() {});
              },
              cursorColor: widget.primaryColor,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(1),
              style: TextStyle(
                color: widget.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.greyColor,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty) _buildClearButton(),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _searchController.clear();
            setState(() {});
          },
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: widget.textColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: widget.textColor.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isDropdownOpen
            ? widget.primaryColor
            : (_isHovering || _isSearchFocused)
                ? widget.primaryColor.withOpacity(0.12)
                : widget.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isDropdownOpen
            ? [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          if (_isDropdownOpen) {
            _hideDropdown();
          } else {
            _showDropdown(context);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: _selectedCategory,
              color: _isDropdownOpen ? AppColors.backgroundColorLight : null,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isDropdownOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _isDropdownOpen ? Colors.white : widget.primaryColor,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }
}
