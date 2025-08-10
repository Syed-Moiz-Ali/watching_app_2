import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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
  final int index;

  const SourceCard({
    required this.source,
    this.index = 0,
    super.key,
  });

  @override
  State<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<SourceCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.015,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    final provider = context.read<SourceProvider>();
    provider.selectedQuery = widget.source.query.entries.first.value;
    provider.updateState();

    switch (widget.source.type) {
      case '1':
      case '5':
        NH.nameNavigateTo(AppRoutes.videoList,
            arguments: {"source": widget.source});
        break;
      case '3':
        NH.nameNavigateTo(AppRoutes.wallpapers,
            arguments: {"source": widget.source});
        break;
      case '2':
        NH.nameNavigateTo(AppRoutes.tiktok,
            arguments: {"source": widget.source});
        break;
      case '4':
        NH.navigateTo(Manga(source: widget.source));
        break;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case '1':
        return const Color(0xFF6366F1);
      case '3':
        return const Color(0xFF10B981);
      case '4':
        return const Color(0xFFF59E0B);
      case '5':
        return const Color(0xFFEC4899);
      case '2':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '1':
        return Icons.play_circle_outline_rounded;
      case '3':
        return Icons.image_outlined;
      case '4':
        return Icons.menu_book_outlined;
      case '5':
        return Icons.movie_outlined;
      case '2':
        return Icons.music_video_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case '1':
        return 'Video';
      case '3':
        return 'Wallpaper';
      case '4':
        return 'Manga';
      case '5':
        return 'Anime';
      case '2':
        return 'TikTok';
      default:
        return 'Content';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getTypeColor(widget.source.type);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPressed ? 0.98 : _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isHovered
                            ? typeColor.withOpacity(0.4)
                            : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
                        width: _isHovered ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 8 + (_elevationAnimation.value * 12),
                          offset:
                              Offset(0, 4 + (_elevationAnimation.value * 8)),
                          spreadRadius: -2,
                        ),
                        if (_isHovered)
                          BoxShadow(
                            color: typeColor.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -4,
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleTap,
                          borderRadius: BorderRadius.circular(20),
                          splashColor: typeColor.withOpacity(0.1),
                          highlightColor: typeColor.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                // Enhanced Icon Container
                                _buildIconContainer(typeColor),

                                const SizedBox(width: 18),

                                // Enhanced Content
                                Expanded(
                                  child: _buildContent(typeColor, theme),
                                ),

                                const SizedBox(width: 12),

                                // Enhanced Arrow
                                _buildArrow(typeColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      )
          .animate(delay: (widget.index * 80).ms)
          .fadeIn(duration: 500.ms, curve: Curves.easeOutQuart)
          .slideX(begin: 0.15, duration: 500.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildIconContainer(Color typeColor) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: typeColor.withOpacity(_isHovered ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withOpacity(_isHovered ? 0.3 : 0.15),
          width: 1,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Icon background with subtle gradient
              if (_isHovered)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        typeColor.withOpacity(0.1),
                        typeColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),

              // Main icon
              Center(
                child: ImageWidget(
                  imagePath: widget.source.icon,
                  height: 32,
                  width: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color typeColor, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Source Name
        Row(
          children: [
            Expanded(
              child: TextWidget(
                text: widget.source.name,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color:
                    _isHovered ? typeColor : theme.textTheme.bodyLarge?.color,
              ),
            ),
            // Verified indicator
            if (widget.source.nsfw != '1')
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified,
                  size: 12,
                  color: Colors.green,
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // Enhanced badges row
        Row(
          children: [
            // Type badge with refined styling
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: typeColor.withOpacity(0.25),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(widget.source.type),
                    size: 13,
                    color: typeColor,
                  ),
                  const SizedBox(width: 5),
                  TextWidget(
                    text: _getTypeLabel(widget.source.type),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                    letterSpacing: 0.2,
                  ),
                ],
              ),
            ),

            // NSFW badge with better styling
            if (widget.source.nsfw == '1') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.25),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 11,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 4),
                    TextWidget(
                      text: '18+',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.red[600],
                      letterSpacing: 0.3,
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Popularity indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 10,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 3),
                  TextWidget(
                    text: 'Popular',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArrow(Color typeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _isHovered ? typeColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isHovered ? typeColor.withOpacity(0.2) : Colors.transparent,
          width: 1,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(_isHovered ? 2.0 : 0.0, 0.0),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: _isHovered ? typeColor : Colors.grey[500],
          size: 16,
        ),
      ),
    );
  }
}
