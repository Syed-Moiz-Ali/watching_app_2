// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:watching_app_2/core/global/globals.dart';
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

class _UltraPremiumSearchBarState extends State<UltraPremiumSearchBar> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearchFocused = false;
  String _selectedCategory = 'All';
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_handleFocusChange);
    _selectedCategory = widget.categories.first;

    var keyboardVisibilityController = KeyboardVisibilityController();
    if (kDebugMode) {
      print('Keyboard visibility: ${keyboardVisibilityController.isVisible}');
    }

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
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
      if (!_isSearchFocused) {
        _hideDropdown();
      }
    });
  }

  void _showDropdown(BuildContext context) {
    _removeDropdownOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + size.height + 8,
        left: position.dx,
        width: size.width,
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1F1F1F).withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildDropdownContent(isDark),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 150.ms, curve: Curves.easeOut)
            .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic)
            .scale(
              begin: const Offset(0.96, 0.96),
              curve: Curves.easeOutCubic,
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

  Widget _buildDropdownContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;

          return _buildCategoryItem(category, isDark)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 40 * index))
              .slideX(
                begin: -0.2,
                end: 0,
                curve: Curves.easeOutCubic,
              );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(String category, bool isDark) {
    final bool isSelected = category == _selectedCategory;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected
            ? widget.primaryColor.withOpacity(isDark ? 0.15 : 0.08)
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
            widget.onCategoryChanged(category);
            _hideDropdown();
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? widget.primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextWidget(
                    text: category,
                    color: isSelected
                        ? widget.primaryColor
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: widget.primaryColor,
                  )
                      .animate()
                      .scale(delay: 80.ms, curve: Curves.elasticOut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSearchFocused
                ? widget.primaryColor.withOpacity(isDark ? 0.6 : 0.5)
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08)),
            width: _isSearchFocused ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isSearchFocused
                  ? widget.primaryColor.withOpacity(isDark ? 0.15 : 0.08)
                  : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: _isSearchFocused ? 16 : 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildSearchContent(isDark),
      ),
    );
  }

  Widget _buildSearchContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: _isSearchFocused
                ? widget.primaryColor
                : (isDark ? Colors.grey[500] : Colors.grey[400]),
            size: 20,
          )
              .animate(target: _isSearchFocused ? 1 : 0)
              .tint(color: widget.primaryColor),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              onEditingComplete: () {
                widget.onSearch(_searchController.text, _selectedCategory);
                _searchFocusNode.unfocus();
              },
              onChanged: (_) => setState(() {}),
              cursorColor: widget.primaryColor,
              cursorWidth: 1.5,
              cursorRadius: const Radius.circular(1),
              style: SMA.baseTextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: SMA.baseTextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            _buildClearButton(isDark)
                .animate()
                .fadeIn(duration: 150.ms)
                .scale(curve: Curves.easeOut),
          const SizedBox(width: 8),
          _buildFilterButton(isDark),
        ],
      ),
    );
  }

  Widget _buildClearButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        _searchController.clear();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 14,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        if (_isDropdownOpen) {
          _hideDropdown();
        } else {
          _showDropdown(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isDropdownOpen
              ? widget.primaryColor
              : widget.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: _selectedCategory,
              color: _isDropdownOpen
                  ? Colors.white
                  : (isDark ? widget.primaryColor.withOpacity(0.9) : widget.primaryColor),
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _isDropdownOpen
                  ? Colors.white
                  : (isDark ? widget.primaryColor.withOpacity(0.9) : widget.primaryColor),
              size: 16,
            ).animate(target: _isDropdownOpen ? 1 : 0).rotate(end: 0.5),
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
