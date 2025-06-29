import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/enums/enums.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/presentation/provider/source_provider.dart';
import 'package:watching_app_2/presentation/provider/theme_provider.dart';
import 'package:watching_app_2/presentation/provider/webview_provider.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/shared/screens/favorites/favorite_button.dart';
import 'package:watching_app_2/shared/widgets/misc/gap.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../data/scrapers/scraper_service.dart';
import '../../../../presentation/provider/similar_content_provider.dart';
import 'dart:ui';
import 'dart:developer';

class ContentDetail extends StatefulWidget {
  final ContentItem item;
  const ContentDetail({super.key, required this.item});

  @override
  State<ContentDetail> createState() => _ContentDetailState();
}

class _ContentDetailState extends State<ContentDetail> {
  late ScrollController _scrollController;
  double _scrollProgress = 0;
  ContentItem? detailItem;

  @override
  void initState() {
    super.initState();
    detailItem = widget.item;
    var provider = Provider.of<WebviewProvider>(context, listen: false);
    log("this is the content detail page and the item is ${detailItem!.toJson()}");
    getDetail();
    provider.loadVideos(detailItem!);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollProgress = (_scrollController.offset / 200).clamp(0.0, 1.0);
        });
      });
  }

  getDetail() async {
    if (detailItem!.source.hasEpisodes == true) {
      final scraperService = ScraperService(detailItem!.source);

      var res = await scraperService.getDetails(SMA.formatImage(
          baseUrl: detailItem!.source.url, image: detailItem!.contentUrl));
      if (mounted) {
        setState(() {
          detailItem!.detailContent = res.first.detailContent;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SimilarContentProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 15 * _scrollProgress,
              sigmaY: 15 * _scrollProgress,
            ),
            child: AppBar(
              elevation: 0,
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
              leading: _buildIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                FavoriteButton(
                    item: detailItem!, contentType: ContentTypes.VIDEO),
                _buildIconButton(
                  icon: Icons.share_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 600.ms),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image Section with Gradient Overlay
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Background Image with Parallax Effect
                    Container(
                      height: 65.h,
                      width: double.infinity,
                      child: Hero(
                        tag: detailItem!.thumbnailUrl,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ImageWidget(
                              imagePath: SMA.formatImage(
                                  image: detailItem!.thumbnailUrl,
                                  baseUrl: detailItem!.source.url),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              borderRadius: BorderRadius.zero,
                            ),
                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                    Theme.of(context).scaffoldBackgroundColor,
                                  ],
                                  stops: const [0.0, 0.7, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .scale(begin: const Offset(1.1, 1.1), duration: 800.ms)
                        .fadeIn(duration: 600.ms),

                    // Floating Play Button
                    Positioned(
                      bottom: 3.h,
                      right: 5.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            NH.nameNavigateTo(AppRoutes.video,
                                arguments: {'item': detailItem!});
                          },
                          icon: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                          padding: EdgeInsets.all(4.w),
                        ),
                      )
                          .animate(delay: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8))
                          .fadeIn(duration: 600.ms),
                    ),
                  ],
                ),
              ),

              // Content Section
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),

                        // Title Section
                        _buildTitle()
                            .animate(delay: 200.ms)
                            .slideY(begin: 0.3, duration: 600.ms)
                            .fadeIn(),

                        // SizedBox(height: 2.h),

                        // // Description
                        // _buildDescription()
                        //     .animate(delay: 300.ms)
                        //     .slideY(begin: 0.3, duration: 600.ms)
                        //     .fadeIn(),

                        SizedBox(height: 3.h),

                        // Quick Info Cards
                        _buildQuickInfo()
                            .animate(delay: 400.ms)
                            .slideY(begin: 0.3, duration: 600.ms)
                            .fadeIn(),

                        SizedBox(height: 4.h),

                        // Watch Button
                        _buildWatchButton()
                            .animate(delay: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8))
                            .fadeIn(duration: 600.ms),

                        SizedBox(height: 4.h),

                        // Episodes Section
                        if (detailItem!.detailContent != null &&
                            detailItem!.detailContent!.chapter!.isNotEmpty)
                          _buildEpisodesSection()
                              .animate(delay: 600.ms)
                              .slideY(begin: 0.3, duration: 600.ms)
                              .fadeIn(),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20.sp),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: detailItem!.title,
          styleType: TextStyleType.heading1,
          fontSize: 22.sp,
          maxLine: 10,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            _buildChip(detailItem!.quality, Colors.purple),
            SizedBox(width: 2.w),
            _buildChip(detailItem!.duration, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: TextWidget(
        text: text,
        fontSize: 14.sp,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDescription() {
    if (detailItem!.detailContent?.discription == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: TextWidget(
        text: detailItem!.detailContent!.discription!,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
        maxLine: 4,
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoTile(
            icon: Icons.source_rounded,
            title: 'Source',
            value: detailItem!.source.name,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildInfoTile(
            icon: Icons.schedule_rounded,
            title: 'Time',
            value: detailItem!.time,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 1.h),
          TextWidget(
            text: title,
            fontSize: 12.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 0.5.h),
          TextWidget(
            text: value,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            maxLine: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(25.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            NH.nameNavigateTo(AppRoutes.video,
                arguments: {'item': detailItem!});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 2.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline_rounded,
                  size: 24.sp, color: Colors.white),
              SizedBox(width: 2.w),
              TextWidget(
                text: 'Watch Now',
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodesSection() {
    if (detailItem!.detailContent?.chapter == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: "Episodes",
              styleType: TextStyleType.heading2,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                ),
              ),
              child: TextWidget(
                text: "${detailItem!.detailContent!.chapter!.length}",
                fontSize: 12.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 35.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: detailItem!.detailContent!.chapter!.length,
            itemBuilder: (context, index) {
              var chapter = detailItem!.detailContent!.chapter![index];
              return _buildEpisodeCard(chapter, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeCard(chapter, int index) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      width: 50.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          var contentItem = ContentItem(
            title: chapter.chapterId ??
                ''
                    .replaceAll(widget.item.source.url, "")
                    .replaceAll("videos", ''),
            thumbnailUrl: chapter.chapterImage ?? '',
            contentUrl: chapter.chapterId ?? '',
            source: detailItem!.source,
            scrapedAt: DateTime.now(),
            addedAt: DateTime.now(),
          );
          NH.nameForceNavigate(AppRoutes.detail,
              arguments: {"item": contentItem});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ImageWidget(
                    imagePath: chapter.chapterImage ?? '',
                    height: 20.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2.w,
                  right: 2.w,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            // Episode Info
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "Episode ${index + 1}",
                    fontSize: 11.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 1.h),
                  TextWidget(
                    text: chapter.chapterName ?? 'Untitled',
                    maxLine: 2,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.3, duration: 400.ms)
        .fadeIn();
  }
}
