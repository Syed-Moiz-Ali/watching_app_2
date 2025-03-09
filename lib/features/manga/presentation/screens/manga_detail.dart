import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/features/manga/presentation/screens/chapter.dart';
import 'package:watching_app_2/presentation/provider/manga_detail_provider.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

class MangaDetailScreen extends StatefulWidget {
  final ContentItem item;

  const MangaDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  _MangaDetailScreenState createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late ScrollController _scrollController;
  bool _isScrolled = false;
  double _scrollThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Header animations (image and title)
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _imageScaleAnimation = Tween<double>(begin: 1.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Content animations (details and chapters)
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    var provider = context.read<MangaDetailProvider>();
    provider.loadMangaDetails(widget.item);

    // Staggered animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _contentAnimationController.forward();
      });
    });
  }

  void _onScroll() {
    if (_scrollController.offset > _scrollThreshold && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= _scrollThreshold && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _scrollController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  Widget _buildGlassContainer({required Widget child, double radius = 16.0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      color: Colors.black,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   width: double.infinity,
              //   height: MediaQuery.of(context).size.height * 0.6,
              //   color: Colors.grey[800],
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  ...List.generate(
                      5,
                      (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              width: double.infinity,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(String label, {Color? color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.15) ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color?.withOpacity(0.3) ?? Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? Colors.white).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color ?? Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.white,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList(ContentItem details, int chapterCount) {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _contentFadeAnimation,
          child: SlideTransition(
            position: _contentSlideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Chapters",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      _buildGlassContainer(
                        radius: 12,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            "$chapterCount Chapters",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: chapterCount, // Limiting to 20 for performance
                  itemBuilder: (context, index) {
                    final chapterNum = chapterCount - index;

                    // Apply staggered animation for chapters
                    final staggeredAnimation = CurvedAnimation(
                      parent: _contentAnimationController,
                      curve: Interval(
                        0.4 + (index * 0.03 > 0.5 ? 0.5 : index * 0.03),
                        0.9 + (index * 0.01 > 0.1 ? 0.1 : index * 0.01),
                        curve: Curves.easeOut,
                      ),
                    );

                    return FadeTransition(
                      opacity: staggeredAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(staggeredAnimation),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGlassContainer(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // var newDetail = details;
                                var updatedDetails = details.copyWith(
                                  chapterId: details.chapterId.replaceAll(
                                      "$chapterCount", chapterNum.toString()),
                                );
                                NH.navigateTo(MangaReaderScreen(
                                  item: updatedDetails,
                                ));
                                // Handle chapter selection
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.purpleAccent,
                                            Colors.blueAccent
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.purpleAccent
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$chapterNum",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Chapter $chapterNum",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            index < 3
                                                ? "Updated recently"
                                                : "Updated ${index} days ago",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
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
                if (chapterCount > 20)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        label: const Text(
                          "View All Chapters",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedBuilder(
          animation: _headerAnimationController,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _isScrolled
                  ? Colors.black.withOpacity(0.8)
                  : Colors.transparent,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      if (_isScrolled)
                        Expanded(
                          child: FadeTransition(
                            opacity: _headerFadeAnimation,
                            child: Text(
                              widget.item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: Consumer<MangaDetailProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadMangaDetails(widget.item),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (provider.mangaDetail == null) {
            return const Center(
              child: Text(
                'No details available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final details = provider.mangaDetail!;
          final statusColor =
              details.status.trim().toLowerCase().contains("ongoing")
                  ? Colors.greenAccent
                  : details.status.trim().toLowerCase().contains("completed")
                      ? Colors.blueAccent
                      : Colors.orangeAccent;

          return SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image with animated scaling and gradient overlay
                AnimatedBuilder(
                  animation: _headerAnimationController,
                  builder: (context, child) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Animated image
                          Transform.scale(
                            scale: _imageScaleAnimation.value,
                            child: Hero(
                              tag:
                                  'manga_${widget.item.contentUrl ?? widget.item.title}',
                              child: Image.network(
                                SMA.formatImage(
                                  image: widget.item.thumbnailUrl,
                                  baseUrl: widget.item.source.url,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.5),
                                  Colors.black.withOpacity(0.9),
                                  Colors.black,
                                ],
                                stops: [0.0, 0.5, 0.85, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          // Title and info positioned at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: FadeTransition(
                              opacity: _headerFadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.item.title,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Row(
                                    //   children: [
                                    //     _buildInfoTag(
                                    //       "Author: ${details.author ?? 'Unknown'}",
                                    //       icon: Icons.person,
                                    //       color: Colors.white,
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Content section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AnimatedBuilder(
                    animation: _contentAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: SlideTransition(
                          position: _contentSlideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildInfoTag(
                                    details.status.trim(),
                                    color: statusColor,
                                    icon: details.status
                                            .trim()
                                            .toLowerCase()
                                            .contains("ongoing")
                                        ? Icons.update
                                        : Icons.check_circle,
                                  ),
                                  _buildInfoTag(
                                    "${details.chapterCount} Chapters",
                                    color: Colors.amberAccent,
                                    icon: Icons.menu_book,
                                  ),
                                  ...details.genre
                                      .split(", ")
                                      .take(3)
                                      .map((genre) => _buildInfoTag(
                                            genre.trim(),
                                            color: Colors.purpleAccent,
                                          ))
                                      .toList(),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Description
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Synopsis",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildGlassContainer(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        details.discription ??
                                            "A captivating story of adventure and discovery. Follow the journey of our protagonist as they navigate through challenges and grow stronger with each chapter.",
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.purpleAccent,
                                            Colors.blueAccent
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.purpleAccent
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Read logic
                                        },
                                        icon: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "START READING",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildGlassContainer(
                                    radius: 16,
                                    child: SizedBox(
                                      height: 56,
                                      width: 56,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.download,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          // Download logic
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // Chapter list
                              provider.isLoading
                                  ? _buildShimmerPlaceholder()
                                  : _buildChapterList(
                                      details,
                                      double.tryParse(details.chapterCount
                                                  .replaceAll("Chapter", '')
                                                  .trim())
                                              ?.toInt() ??
                                          0),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
