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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
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
        return Icons.play_circle_filled_rounded;
      case '3':
        return Icons.image_rounded;
      case '4':
        return Icons.menu_book_rounded;
      case '5':
        return Icons.movie_rounded;
      case '2':
        return Icons.music_video_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case '1':
        return 'Video';
      case '3':
        return 'Photos';
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.w),
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
                    color: isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isHovered
                          ? typeColor.withOpacity(0.3)
                          : (isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.06)),
                      width: _isHovered ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: _isHovered ? 12 : 8,
                        offset: Offset(0, _isHovered ? 6 : 2),
                      ),
                      if (_isHovered)
                        BoxShadow(
                          color: typeColor.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _handleTap,
                      borderRadius: BorderRadius.circular(16),
                      splashColor: typeColor.withOpacity(0.08),
                      highlightColor: typeColor.withOpacity(0.04),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          children: [
                            _buildIconContainer(typeColor, isDark),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: _buildContent(typeColor, theme, isDark),
                            ),
                            SizedBox(width: 3.w),
                            _buildArrow(typeColor, isDark),
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
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 60))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideX(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildIconContainer(Color typeColor, bool isDark) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: typeColor.withOpacity(_isHovered ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: typeColor.withOpacity(_isHovered ? 0.25 : 0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // Subtle gradient background on hover
            if (_isHovered)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      typeColor.withOpacity(0.08),
                      typeColor.withOpacity(0.02),
                    ],
                  ),
                ),
              ),

            // Icon or fallback
            Center(
              child: widget.source.icon.isNotEmpty
                  ? ImageWidget(
                      imagePath: widget.source.icon,
                      height: 32,
                      width: 32,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      _getTypeIcon(widget.source.type),
                      color: typeColor,
                      size: 28,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color typeColor, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source name with verified badge
        Row(
          children: [
            Expanded(
              child: TextWidget(
                text: widget.source.name,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: isDark ? Colors.white : Colors.black87,
                maxLine: 1,
              ),
            ),
            if (widget.source.nsfw != '1')
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 12,
                  color: Colors.green,
                ),
              ),
          ],
        ),

        SizedBox(height: 2.w),

        // Badges row
        Wrap(
          spacing: 2.w,
          runSpacing: 1.w,
          children: [
            // Type badge
            _buildBadge(
              icon: _getTypeIcon(widget.source.type),
              label: _getTypeLabel(widget.source.type),
              color: typeColor,
            ),

            // NSFW badge
            if (widget.source.nsfw == '1')
              _buildBadge(
                icon: Icons.warning_rounded,
                label: '18+',
                color: Colors.red,
                isWarning: true,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    bool isWarning = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          SizedBox(width: 1.w),
          TextWidget(
            text: label,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.2,
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(Color typeColor, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _isHovered ? typeColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHovered
              ? typeColor.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: _isHovered
            ? typeColor
            : (isDark ? Colors.grey[500] : Colors.grey[400]),
        size: 14,
      ),
    );
  }
}
