import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:watching_app_2/core/constants/colors.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    required this.recentSearches,
    required this.onRecentSearchesUpdated,
    this.hintText = 'Search your content...',
    this.primaryColor = const Color(0xFF6C5CE7), // Premium violet
    this.backgroundColor = Colors.white, // Light background
    this.textColor = const Color(0xFF2D3748), // Dark slate for text
  });

  final Color backgroundColor;
  final String hintText;
  final VoidCallback onFilterTap;
  final Function(List<String>) onRecentSearchesUpdated;
  final Function(String) onSearch;
  final Color primaryColor;
  final List<String> recentSearches;
  final Color textColor;

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with TickerProviderStateMixin {
  late AnimationController _bounceAnimController;
  late Animation<double> _bounceAnimation;
  late AnimationController _focusAnimController;
  late Animation<double> _focusAnimation;
  bool _isSearchFocused = false;
  OverlayEntry? _overlayEntry;
  late AnimationController _recentSearchesAnimController;
  late AnimationController _searchBarAnimController;
  late Animation<double> _searchBarAnimation;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _shimmerAnimController;
  late Animation<double> _shimmerAnimation;
  late AnimationController _pulseAnimController;
  late Animation<double> _pulseAnimation;
  bool _showRecentSearches = false;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void dispose() {
    _removeRecentSearchesOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchBarAnimController.dispose();
    _focusAnimController.dispose();
    _bounceAnimController.dispose();
    _shimmerAnimController.dispose();
    _recentSearchesAnimController.dispose();
    _pulseAnimController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_handleFocusChange);

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
    // Entry animation - smoother and more premium feel
    _searchBarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarAnimController,
      curve: Curves.easeOutExpo, // More premium easing
    );

    // Focus animation - refined transition
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _focusAnimation = CurvedAnimation(
      parent: _focusAnimController,
      curve: Curves.easeOutCubic, // Smoother transition
    );

    // Bounce animation - more subtle and elegant
    _bounceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceAnimController,
      curve: Curves.easeOutBack, // Nicer bounce
    );

    // Shimmer animation - subtle gradient flow
    _shimmerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Slower, more elegant
    )..repeat();
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerAnimController,
      curve: Curves.easeInOutSine,
    );

    // Pulse animation for search icon - subtle attention effect
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Recent searches animation
    _recentSearchesAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Start entry animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchBarAnimController.forward();
    });
  }

  void _handleFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
      if (_isSearchFocused) {
        _focusAnimController.forward();
        _bounceAnimController.forward(from: 0.0);
        _pulseAnimController.stop();
        if (widget.recentSearches.isNotEmpty) {
          _showRecentSearches = true;
          _recentSearchesAnimController.forward();
        }
      } else {
        _focusAnimController.reverse();
        _pulseAnimController.repeat(reverse: true);
        if (_showRecentSearches) {
          _recentSearchesAnimController.reverse().then((_) {
            setState(() {
              _showRecentSearches = false;
              _removeRecentSearchesOverlay();
            });
          });
        }
      }
    });
  }

  void _removeRecentSearchesOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;

    List<String> updatedSearches = List.from(widget.recentSearches);
    updatedSearches.remove(query);
    updatedSearches.insert(0, query);

    if (updatedSearches.length > 5) {
      updatedSearches = updatedSearches.sublist(0, 5);
    }

    widget.onRecentSearchesUpdated(updatedSearches);
  }

  Widget _buildSearchBarContainer() {
    // Calculate interpolated values based on focus state
    final double horizontalPadding = lerpDouble(16, 12, _focusAnimation.value)!;
    final double verticalPadding = lerpDouble(14, 8, _focusAnimation.value)!;
    final double borderRadius = lerpDouble(28, 16, _focusAnimation.value)!;
    final double elevation = lerpDouble(4, 16, _focusAnimation.value)!;

    // Dynamic glass effect gradient
    final Color gradientStart = Color.lerp(
      widget.backgroundColor,
      widget.primaryColor.withOpacity(0.05),
      _isSearchFocused ? 0.15 : 0.02,
    )!;

    final Color gradientEnd = Color.lerp(
      widget.backgroundColor,
      widget.primaryColor.withOpacity(0.1),
      _isSearchFocused ? 0.25 : 0.05,
    )!;

    // Shimmer effect colors
    const Color shimmerColor = AppColors.primaryColor;

    final Color borderColor = _isSearchFocused
        ? AppColors.primaryColor.withOpacity(0.8)
        : Color.lerp(AppColors.primaryColor, widget.primaryColor, .1)!
            .withOpacity(0.5);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        border: Border.all(
          color: borderColor,
          width: _isSearchFocused ? 2.0 : 1.3,
        ),
        boxShadow: [
          // BoxShadow(
          //   color: _isSearchFocused
          //       ? shimmerColor.withOpacity(0.2)
          //       : widget.primaryColor.withOpacity(0.1),
          //   blurRadius: elevation,
          //   spreadRadius: elevation / 4,
          //   offset: const Offset(0, 3),
          // ),
          if (_isSearchFocused)
            BoxShadow(
              color: shimmerColor.withOpacity(0.04),
              blurRadius: elevation * 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: _buildSearchContent(borderRadius),
    );
  }

  Widget _buildSearchContent(double borderRadius) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildSearchIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                onEditingComplete: () {
                  widget.onSearch(_searchController.text);
                  _addToRecentSearches(_searchController.text);
                  _searchFocusNode.unfocus();
                },
                onChanged: (value) {
                  setState(() {});
                },
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: _isSearchFocused
                        ? widget.textColor
                        : widget.textColor.withOpacity(.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            _buildClearButton(),
            if (!_isSearchFocused && _searchController.text.isEmpty)
              _buildFilterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchIcon() {
    final Color iconColor = _isSearchFocused
        ? widget.primaryColor
        : Color.lerp(widget.textColor, widget.primaryColor, 0.5)!
            .withOpacity(0.7);

    final gradient = LinearGradient(
      colors: [
        widget.primaryColor,
        HSLColor.fromColor(widget.primaryColor)
            .withLightness(
                HSLColor.fromColor(widget.primaryColor).lightness + 0.15)
            .toColor(),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AnimatedBuilder(
      animation: _isSearchFocused ? _bounceAnimation : _pulseAnimation,
      builder: (context, child) {
        final double scale = _isSearchFocused
            ? 1.0 + (_bounceAnimation.value * 0.15)
            : _pulseAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isSearchFocused
                  ? widget.primaryColor.withOpacity(0.1)
                  : widget.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              gradient: _isSearchFocused
                  ? LinearGradient(
                      colors: [
                        widget.primaryColor.withOpacity(0.12),
                        widget.primaryColor.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: _isSearchFocused
                  ? [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => _isSearchFocused
                  ? gradient.createShader(bounds)
                  : LinearGradient(colors: [iconColor, iconColor])
                      .createShader(bounds),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClearButton() {
    return AnimatedOpacity(
      opacity: _searchController.text.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        onPressed: () {
          _searchController.clear();
          setState(() {});
        },
        icon: const Icon(
          Icons.close_rounded,
          size: 18,
        ),
        style: IconButton.styleFrom(
          foregroundColor: widget.textColor.withOpacity(0.6),
          backgroundColor: widget.textColor.withOpacity(0.05),
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return AnimatedOpacity(
      opacity: !_isSearchFocused ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        onPressed: widget.onFilterTap,
        icon: const Icon(
          Icons.tune_rounded,
          size: 20,
        ),
        style: IconButton.styleFrom(
          foregroundColor: widget.primaryColor,
          backgroundColor: widget.primaryColor.withOpacity(0.1),
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _searchBarAnimation,
        _focusAnimation,
        _bounceAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        // Enhanced entrance animation
        final double yOffset = 50 * (1 - _searchBarAnimation.value);
        final double scaleValue = 0.95 + (0.05 * _searchBarAnimation.value);

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scaleValue,
            child: Opacity(
              opacity: _searchBarAnimation.value,
              child: _buildSearchBarContainer(),
            ),
          ),
        );
      },
    );
  }
}
