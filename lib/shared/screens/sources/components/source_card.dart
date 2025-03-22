import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import '../../../../presentation/provider/source_provider.dart';

class SourceCard extends StatefulWidget {
  final ContentSource source;

  const SourceCard({required this.source, super.key});

  @override
  State<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<SourceCard> with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _entryController;
  late final AnimationController _hoverController;

  // Entry animations
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  // Hover/interaction animations
  late final Animation<double> _elevationAnimation;
  late final Animation<Color?> _backgroundColorAnimation;
  late final Animation<double> _iconRotationAnimation;

  // Focus handling
  late FocusNode _focusNode;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    // Entry animation controller
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Hover animation controller
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Entry animations
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    // Hover/interaction animations
    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.greyColor.withOpacity(0.05),
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    // Start the entry animation
    _entryController.forward();

    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleHoverChange(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });

    if (isHovering) {
      _hoverController.forward();
    } else if (!_focusNode.hasFocus) {
      _hoverController.reverse();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _hoverController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _hoverController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                child: Material(
                  color: Colors.transparent,
                  child: MouseRegion(
                    onEnter: (_) => _handleHoverChange(true),
                    onExit: (_) => _handleHoverChange(false),
                    child: Focus(
                      focusNode: _focusNode,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          var provider = context.read<SourceProvider>();
                          provider.selectedQuery =
                              widget.source.query.entries.first.value;
                          provider.updateState();
                          if (widget.source.type == '1') {
                            NH.nameNavigateTo(AppRoutes.videoList,
                                arguments: {"source": widget.source});
                          } else if (widget.source.type == '3') {
                            NH.nameNavigateTo(AppRoutes.wallpapers,
                                arguments: {"source": widget.source});
                          } else if (widget.source.type == '4') {
                            NH.navigateTo(Manga(source: widget.source));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _backgroundColorAnimation.value,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _isHovering || _focusNode.hasFocus
                                  ? AppColors.greyColor.withOpacity(0.6)
                                  : AppColors.greyColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    0.08 * _elevationAnimation.value / 8),
                                blurRadius: 15 * _elevationAnimation.value / 8,
                                offset: Offset(
                                    0, 5 * _elevationAnimation.value / 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Source Icon with glowing effect
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _isHovering || _focusNode.hasFocus
                                      ? [
                                          BoxShadow(
                                            color: theme.primaryColor
                                                .withOpacity(0.1),
                                            blurRadius: 20,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Hero(
                                  tag: 'source_icon_${widget.source.name}',
                                  child: ImageWidget(
                                    imagePath: widget.source.icon,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 20),

                              // Source information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: widget.source.name,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                    const SizedBox(height: 8),

                                    // Content type badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextWidget(
                                        text: _getTypeLabel(widget.source.type),
                                        fontSize: 12.sp,
                                        color: theme.primaryColor,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // NSFW indicator
                                    if (widget.source.nsfw == '1')
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.errorColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.lock_outline,
                                                  size: 14.sp,
                                                  color: AppColors.errorColor,
                                                ),
                                                const SizedBox(width: 4),
                                                TextWidget(
                                                  text: 'NSFW',
                                                  fontSize: 12.sp,
                                                  color: AppColors.errorColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              // Arrow indicator with rotation animation
                              Transform.rotate(
                                angle: _iconRotationAnimation.value,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _isHovering || _focusNode.hasFocus
                                        ? theme.primaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.sp,
                                    color: _isHovering || _focusNode.hasFocus
                                        ? theme.primaryColor
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  // Helper method to convert type codes to readable labels
  String _getTypeLabel(String type) {
    switch (type) {
      case '1':
        return 'Video';
      case '3':
        return 'Wallpaper';
      case '4':
        return 'Manga';
      default:
        return 'Type: $type';
    }
  }
}
