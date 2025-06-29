import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watching_app_2/core/constants/colors.dart';
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
  bool _isHovering = false;

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

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + size.height - 12,
        left: position.dx,
        width: size.width,
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildDropdownContent(),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms, curve: Curves.easeOut)
            .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic)
            .scale(begin: const Offset(0.95, 0.95)),
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;

          return _buildCategoryItem(category)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * index))
              .slideX(begin: -0.3, end: 0, curve: Curves.easeOutCubic);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(String category) {
    final bool isSelected = category == _selectedCategory;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? widget.primaryColor.withOpacity(0.1)
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? widget.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextWidget(
                    text: category,
                    color:
                        isSelected ? widget.primaryColor : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: widget.primaryColor,
                  ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isSearchFocused
                ? widget.primaryColor.withOpacity(0.8)
                : Colors.grey.shade600,
            width: _isSearchFocused ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isSearchFocused
                  ? widget.primaryColor.withOpacity(0.1)
                  : Colors.black.withOpacity(_isHovering ? 0.08 : 0.04),
              blurRadius: _isSearchFocused ? 20 : 15,
              spreadRadius: _isSearchFocused ? 2 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _buildSearchContent(),
      )
          .animate(target: _isSearchFocused ? 1 : 0)
          .scale(end: const Offset(1.02, 1.02), curve: Curves.easeOut)
          .then()
          .shimmer(
            duration: 1500.ms,
            color: widget.primaryColor.withOpacity(0.1),
          ),
    );
  }

  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color:
                _isSearchFocused ? widget.primaryColor : Colors.grey.shade500,
            size: 22,
          )
              .animate(target: _isSearchFocused ? 1 : 0)
              .scale(end: const Offset(1.1, 1.1))
              .tint(color: widget.primaryColor),
          const SizedBox(width: 16),
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
              cursorWidth: 2,
              cursorRadius: const Radius.circular(1),
              style: SMA.baseTextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: SMA.baseTextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            _buildClearButton()
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(curve: Curves.elasticOut),
          const SizedBox(width: 8),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: () {
        _searchController.clear();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () {
        if (_isDropdownOpen) {
          _hideDropdown();
        } else {
          _showDropdown(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isDropdownOpen
              ? widget.primaryColor
              : widget.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isDropdownOpen
              ? [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: _selectedCategory,
              color: _isDropdownOpen ? Colors.white : widget.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _isDropdownOpen ? Colors.white : widget.primaryColor,
              size: 18,
            ).animate(target: _isDropdownOpen ? 1 : 0).rotate(end: 0.5),
          ],
        ),
      )
          .animate(target: _isDropdownOpen ? 1 : 0)
          .scale(end: const Offset(1.05, 1.05), curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }
}
