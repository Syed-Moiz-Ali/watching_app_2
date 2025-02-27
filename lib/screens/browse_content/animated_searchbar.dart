import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'package:watching_app_2/core/constants/color_constants.dart';

class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onFilterTap;
  final String hintText;
  final Color primaryColor;

  const AnimatedSearchBar({
    Key? key,
    required this.onSearch,
    required this.onFilterTap,
    this.hintText = 'Search your content...',
    this.primaryColor = const Color(0xFF6C63FF),
  }) : super(key: key);

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearchFocused = false;

  // Animations
  late AnimationController _searchBarAnimController;
  late Animation<double> _searchBarAnimation;

  late AnimationController _rippleAnimController;
  late Animation<double> _rippleAnimation;

  late AnimationController _shimmerAnimController;
  late Animation<double> _shimmerAnimation;

  late AnimationController _bounceAnimController;
  late Animation<double> _bounceAnimation;

  late AnimationController _rotateAnimController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _searchFocusNode.addListener(_handleFocusChange);

    // Entry animation controller
    _searchBarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarAnimController,
      curve: Curves.easeOutCubic,
    );

    // Ripple effect animation
    _rippleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rippleAnimation = CurvedAnimation(
      parent: _rippleAnimController,
      curve: Curves.easeOut,
    );

    // Shimmer animation
    _shimmerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerAnimController,
      curve: Curves.easeInOut,
    );

    // Bounce animation
    _bounceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bounceAnimation = CurvedAnimation(
      parent: _bounceAnimController,
      curve: Curves.elasticOut,
    );

    // Rotate animation
    _rotateAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _rotateAnimController,
        curve: Curves.easeInOut,
      ),
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
        _rippleAnimController.forward(from: 0.0);
        _bounceAnimController.forward(from: 0.0);
        _rotateAnimController.forward();
      } else {
        _rotateAnimController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchBarAnimController.dispose();
    _rippleAnimController.dispose();
    _shimmerAnimController.dispose();
    _bounceAnimController.dispose();
    _rotateAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _searchBarAnimation,
        _rippleAnimation,
        _shimmerAnimation,
        _bounceAnimation,
        _rotateAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _searchBarAnimation.value)),
          child: Opacity(
            opacity: _searchBarAnimation.value,
            child: _buildSearchBarContainer(),
          ),
        );
      },
    );
  }

  Widget _buildSearchBarContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ripple effect
        if (_rippleAnimation.value > 0)
          Positioned.fill(
            child: Opacity(
              opacity: 1 - _rippleAnimation.value,
              child: Transform.scale(
                scale: 0.8 + (_rippleAnimation.value * 0.3),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

        // Main container
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          margin: EdgeInsets.symmetric(
            horizontal: _isSearchFocused ? 5 : 20,
            vertical: _isSearchFocused ? 8 : 16,
          ),
          height: _isSearchFocused ? 65 : 60,
          decoration: BoxDecoration(
            color: widget.primaryColor.withOpacity(0.2),

            borderRadius: BorderRadius.circular(_isSearchFocused ? 20 : 30),
            border: Border.all(
              color: _shimmerBorderColor(),
              width: _isSearchFocused ? 2.0 : 1.5,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: _isSearchFocused
            //         ? widget.primaryColor.withOpacity(0.3)
            //         : Colors.black.withOpacity(0.08),
            //     blurRadius: _isSearchFocused ? 20 : 12,
            //     spreadRadius: _isSearchFocused ? 0.5 : 1,
            //     offset: const Offset(0, 5),
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isSearchFocused ? 20 : 30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: _buildSearchContent(),
            ),
          ),
        ),
      ],
    );
  }

  Color _shimmerBorderColor() {
    // Create a shimmer effect on the border
    if (_isSearchFocused) {
      final shimmerValue = math.sin(_shimmerAnimation.value * 2 * math.pi);
      return Color.lerp(
        AppColors.backgroundColorDark.withOpacity(0.5),
        widget.primaryColor.withOpacity(0.8),
        (shimmerValue + 1) / 2,
      )!;
    } else {
      return AppColors.onPrimaryDark.withOpacity(0.4);
    }
  }

  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          _buildAnimatedSearchIcon(),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              onSubmitted: (value) {
                widget.onSearch(value);
                setState(() {
                  _searchFocusNode.unfocus();
                });
              },
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          // AnimatedCrossFade(
          //   duration: const Duration(milliseconds: 300),
          //   reverseDuration: const Duration(milliseconds: 200),
          //   crossFadeState: _isSearchFocused
          //       ? CrossFadeState.showSecond
          //       : CrossFadeState.showFirst,
          //   firstChild: _buildAnimatedFilterIcon(),
          //   secondChild: _buildAnimatedCloseIcon(),
          //   layoutBuilder:
          //       (topChild, topChildKey, bottomChild, bottomChildKey) {
          //     return Stack(
          //       clipBehavior: Clip.none,
          //       alignment: Alignment.center,
          //       children: [
          //         Positioned(
          //           key: bottomChildKey,
          //           child: bottomChild,
          //         ),
          //         Positioned(
          //           key: topChildKey,
          //           child: topChild,
          //         ),
          //       ],
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSearchIcon() {
    final double iconScale = 1.0 + (_bounceAnimation.value * 0.2);

    return Transform.scale(
      scale: iconScale,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isSearchFocused
              ? widget.primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isSearchFocused
                  ? widget.primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0.5,
            ),
          ],
          gradient: LinearGradient(
            colors: [
              _isSearchFocused
                  ? widget.primaryColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.25),
              _isSearchFocused
                  ? widget.primaryColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.white,
                widget.primaryColor,
                Colors.white,
              ],
              stops: [0.0, _shimmerAnimation.value, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFilterIcon() {
    return GestureDetector(
      onTap: () {
        _bounceAnimController.forward(from: 0.0);
        widget.onFilterTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 0.5,
            ),
          ],
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.white,
                widget.primaryColor,
                Colors.white,
              ],
              stops: [0.0, _shimmerAnimation.value, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCloseIcon() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchController.clear();
          _searchFocusNode.unfocus();
          _bounceAnimController.forward(from: 0.0);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0.5,
            ),
          ],
          gradient: LinearGradient(
            colors: [
              widget.primaryColor.withOpacity(0.5),
              widget.primaryColor.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Transform.rotate(
          angle: _rotateAnimation.value * 2 * math.pi,
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
