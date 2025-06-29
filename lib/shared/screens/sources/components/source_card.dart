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

class _SourceCardState extends State<SourceCard> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTap() {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    final provider = context.read<SourceProvider>();
    provider.selectedQuery = widget.source.query.entries.first.value;
    provider.updateState();

    // Navigation logic with enhanced routing
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
        return const Color(0xFF6366F1); // Indigo for Video
      case '3':
        return const Color(0xFF10B981); // Emerald for Wallpaper
      case '4':
        return const Color(0xFFF59E0B); // Amber for Manga
      case '5':
        return const Color(0xFFEC4899); // Pink for Anime
      case '2':
        return const Color(0xFF8B5CF6); // Violet for TikTok
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '1':
        return Icons.play_circle_outline;
      case '3':
        return Icons.wallpaper_outlined;
      case '4':
        return Icons.book_outlined;
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
    final isInteractive = _isHovered || _isFocused || _isPressed;

    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: widget.index == 0 ? 16 : 0,
      ),
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: _handleTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: isInteractive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.05),
                          AppColors.primaryColor.withOpacity(0.02),
                        ],
                      )
                    : null,
                color: isInteractive
                    ? null
                    : (isDark ? Colors.grey[900] : Colors.white),
                border: Border.all(
                  color: isInteractive
                      ? AppColors.primaryColor.withOpacity(0.3)
                      : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                  width: isInteractive ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Icon Container with Glassmorphism
                        _buildIconContainer(
                            AppColors.primaryColor, isDark, isInteractive),

                        const SizedBox(width: 20),

                        // Content Section
                        Expanded(
                          child: _buildContentSection(theme,
                              AppColors.primaryColor, isDark, isInteractive),
                        ),

                        const SizedBox(width: 16),

                        // Chevron Icon
                        _buildChevronIcon(
                            theme, AppColors.primaryColor, isInteractive),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate(delay: (widget.index * 100).ms)
                .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                .slideX(
                    begin: 0.3, duration: 600.ms, curve: Curves.easeOutQuart)
                .scale(
                    begin: Offset(1.0, .95),
                    duration: 600.ms,
                    curve: Curves.easeOutBack),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color typeColor, bool isDark, bool isInteractive) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow effect
          // if (isInteractive)
          //   Container(
          //     width: 70,
          //     height: 70,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       gradient: RadialGradient(
          //         colors: [
          //           typeColor.withOpacity(0.2),
          //           typeColor.withOpacity(0.0),
          //         ],
          //       ),
          //     ),
          //   )
          //       .animate(target: isInteractive ? 1 : 0)
          //       .scale(duration: 300.ms, curve: Curves.easeOut)
          //       .fadeIn(duration: 300.ms),

          // Main icon
          Hero(
            tag: 'source_icon_${widget.source.name}',
            child: ImageWidget(
              imagePath: widget.source.icon,
              height: 55,
              width: 55,
              fit: BoxFit.contain,
            ),
          )
              .animate(target: isInteractive ? 1 : 0)
              .scale(
                  end: Offset(1.0, 1.1),
                  duration: 300.ms,
                  curve: Curves.easeOut)
              .rotate(end: 0.02, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildContentSection(
      ThemeData theme, Color typeColor, bool isDark, bool isInteractive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Source Name
        TextWidget(
          text: widget.source.name,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: isInteractive ? typeColor : null,
        )
            .animate(target: isInteractive ? 1 : 0)
            .slideX(end: 0.02, duration: 300.ms, curve: Curves.easeOut),

        const SizedBox(height: 12),

        // Type and NSFW badges row
        Row(
          children: [
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(widget.source.type),
                    size: 14,
                    color: typeColor,
                  ),
                  const SizedBox(width: 6),
                  TextWidget(
                    text: _getTypeLabel(widget.source.type),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ).animate(target: isInteractive ? 1 : 0).scale(
                end: Offset(1.0, 1.05),
                duration: 300.ms,
                curve: Curves.easeOut),

            // NSFW badge
            if (widget.source.nsfw == '1') ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 12,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    TextWidget(
                      text: '18+',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.3, duration: 400.ms, curve: Curves.easeOut),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChevronIcon(
      ThemeData theme, Color typeColor, bool isInteractive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isInteractive ? typeColor.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color:
              isInteractive ? typeColor.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isInteractive ? typeColor : Colors.grey[600],
      ),
    )
        .animate(target: isInteractive ? 1 : 0)
        .scale(end: Offset(1.0, 1.1), duration: 300.ms, curve: Curves.easeOut)
        .slideX(end: 0.1, duration: 300.ms, curve: Curves.easeOut)
        .rotate(end: 0.05, duration: 300.ms);
  }
}
