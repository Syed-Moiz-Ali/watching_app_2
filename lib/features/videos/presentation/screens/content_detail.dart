import 'package:flutter/material.dart';
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

class _ContentDetailState extends State<ContentDetail>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _headerOpacity;
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
          _scrollProgress = (_scrollController.offset / 100).clamp(0.0, 1.0);
        });
      });

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    // Header opacity animation
    _headerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.6, 1.0),
    ));

    // Start animations in sequence
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _slideController.forward();
        Future.delayed(const Duration(milliseconds: 100), () {
          _scaleController.forward();
        });
      });
    });
  }

  getDetail() async {
    if (detailItem!.source.hasEpisodes == true) {
      final scraperService = ScraperService(detailItem!.source);

      var res = await scraperService.getDetails(SMA.formatImage(
          baseUrl: detailItem!.source.url, image: detailItem!.contentUrl));
      setState(() {
        detailItem!.detailContent = res.first.detailContent;
      });
      // log("the res is ${res.map((r) => r.toJson())}");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SimilarContentProvider>(context);

    return Scaffold(
      // backgroundColor: AppColors.primaryColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10 * _scrollProgress,
                  sigmaY: 10 * _scrollProgress,
                ),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: AppColors.backgroundColorLight
                      .withOpacity(0.3 * _scrollProgress),
                  leading: _buildAnimatedIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    // _buildAnimatedIconButton(
                    //   icon: Icons.favorite_border,
                    //   onPressed: () {},
                    // ),
                    FavoriteButton(
                        item: detailItem!, contentType: ContentTypes.VIDEO),
                    _buildAnimatedIconButton(
                      icon: Icons.share,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      body: Consumer<ThemeProvider>(builder: (context, provider, _) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Hero Image Section
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Hero(
                    tag: detailItem!.thumbnailUrl,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            height: 60.h,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: AppColors.greyColor.withOpacity(0.7),
                                //     spreadRadius: 8,
                                //     blurRadius: 20,
                                //   ),
                                // ],
                                ),
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.backgroundColorLight,
                                    AppColors.backgroundColorLight
                                        .withOpacity(0.7),
                                    Colors.transparent
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: ImageWidget(
                                imagePath: SMA.formatImage(
                                    image: detailItem!.thumbnailUrl,
                                    baseUrl: detailItem!.source.url),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Floating play button
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FloatingActionButton(
                        backgroundColor: AppColors.primaryColor,
                        onPressed: () {
                          // NH.navigateTo(VideoScreen(item: detailItem!));
                          NH.nameNavigateTo(AppRoutes.video,
                              arguments: {'item': detailItem!});
                        },
                        // backgroundColor: AppColors.primaryColor,
                        child: Icon(
                          Icons.play_arrow,
                          color: AppColors.backgroundColorLight,
                          size: 26.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: provider.isDarkTheme
                            ? [
                                AppColors.backgroundColorDark,
                                AppColors.backgroundColorDark,
                              ]
                            : [
                                AppColors.backgroundColorLight,
                                AppColors.backgroundColorLight,
                              ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomGap(heightFactor: .04),
                          _buildAnimatedTitle(),
                          const CustomGap(heightFactor: .02),
                          _buildMetaData(),
                          // CustomGap(heightFactor: .02),
                          _buildInfoCards(),
                          const CustomGap(heightFactor: .04),
                          _buildWatchButton(),
                          const CustomGap(heightFactor: .04),
                          if (detailItem!.detailContent != null)
                            SizedBox(
                              height: 45.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget(
                                        text: "Episodes",
                                        styleType: TextStyleType.heading2,
                                        fontSize: 22.sp,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 3.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: TextWidget(
                                          text:
                                              "${detailItem!.detailContent!.chapter!.length} Episodes",
                                          fontSize: 12.sp,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: widget
                                          .item.detailContent!.chapter!.length,
                                      itemBuilder: (context, index) {
                                        var chapter = widget.item.detailContent!
                                            .chapter![index];
                                        return GestureDetector(
                                          onTap: () {
                                            var contentItem = ContentItem(
                                                title: chapter.chapterId ??
                                                    ''
                                                        .replaceAll(
                                                            widget.item.source
                                                                .url,
                                                            "")
                                                        .replaceAll(
                                                            "videos", ''),
                                                thumbnailUrl:
                                                    chapter.chapterImage ?? '',
                                                contentUrl:
                                                    chapter.chapterId ?? '',
                                                source: detailItem!.source,
                                                scrapedAt: DateTime.now(),
                                                addedAt: DateTime.now());
                                            NH.nameForceNavigate(
                                                AppRoutes.detail,
                                                arguments: {
                                                  "item": contentItem
                                                });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 4.w),
                                            width: 55.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              // gradient: LinearGradient(
                                              //   begin: Alignment.topLeft,
                                              //   end: Alignment.bottomRight,
                                              //   colors: [
                                              //     AppColors.primaryColor
                                              //         .withOpacity(0.15),
                                              //     AppColors.primaryColor
                                              //         .withOpacity(0.05),
                                              //   ],
                                              // ),
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: AppColors.primaryColor
                                              //         .withOpacity(0.1),
                                              //     blurRadius: 10,
                                              //     offset: const Offset(0, 5),
                                              //   ),
                                              // ],
                                              border: Border.all(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.2),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        ImageWidget(
                                                          imagePath: chapter
                                                                  .chapterImage ??
                                                              '',
                                                          height: 25.h,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          customBorderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          18)),
                                                        ),
                                                        Container(
                                                          height: 25.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Colors
                                                                    .transparent,
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.7),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(3.w),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TextWidget(
                                                            text:
                                                                "Episode ${index + 1}",
                                                            fontSize: 12.sp,
                                                            color: AppColors
                                                                .primaryColor,
                                                          ),
                                                          SizedBox(height: 1.h),
                                                          TextWidget(
                                                            text: chapter
                                                                .chapterName!,
                                                            maxLine: 2,
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  right: 2.w,
                                                  top: 2.w,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(2.w),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // SliverToBoxAdapter(
            //   child: SimilarContent(
            //       similarContents: similarProvider.similarContents),
            // ),
            // SliverAnimatedList(
            //     initialItemCount: detailItem!.detailContent!.chapter!.length,
            //     itemBuilder: (context, index, _) {
            //       var chapter = detailItem!.detailContent!.chapter![index];
            //       log("chapter is ${chapter}");
            //       return Container(
            //         child: ImageWidget(
            //           imagePath: chapter.chapterImage ?? '',
            //           height: 10.w,
            //           width: 10.w,
            //         ),
            //       );
            //     })
          ],
        );
      }),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundColorDark.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(icon, color: AppColors.backgroundColorLight),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return FadeTransition(
      opacity: _headerOpacity,
      child: TextWidget(
        text: detailItem!.title,
        styleType: TextStyleType.heading1,
        maxLine: 5,
      ),
    );
  }

  Widget _buildMetaData() {
    // log("detailItem in meta is ${detailItem!.toJson()}");
    return Column(
      children: [
        if (detailItem!.detailContent != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextWidget(
              text: detailItem!.detailContent!.discription ?? '',
              fontWeight: FontWeight.w600,
              fontSize: 17.sp,
            ),
          ),
        const SizedBox(width: 12),
        TextWidget(
          text: '•',
          color: AppColors.greyColor,
          fontSize: 15.sp,
        ),
        const SizedBox(width: 12),
        TextWidget(
          text: detailItem!.duration,
          color: AppColors.greyColor.withOpacity(.6),
          fontWeight: FontWeight.w500,
          fontSize: 17.sp,
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildInfoCard(
          icon: Icons.high_quality,
          title: 'Quality',
          value: detailItem!.quality,
          color: Colors.purple,
        ),
        _buildInfoCard(
          icon: Icons.access_time,
          title: 'Time',
          value: detailItem!.time,
          color: Colors.orange,
        ),
        _buildInfoCard(
          icon: Icons.source,
          title: 'Source',
          value: detailItem!.source.name,
          color: Colors.green,
        ),
        _buildInfoCard(
          icon: Icons.update,
          title: 'Updated',
          value: (context.read<SourceProvider>().selectedQuery != null)
              ? context
                  .read<SourceProvider>()
                  .selectedQuery!
                  .replaceAll("_", " ")
                  .replaceAll("/", "")
                  .replaceAll("{page}", '')
                  .replaceAll("{filter}", "")
                  .toUpperCase()
              : 'N/A',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                TextWidget(
                  text: title,
                  color: AppColors.greyColor,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                TextWidget(
                  text: value,
                  fontSize: 17.sp,
                  maxLine: 1,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchButton() {
    return Center(
      child: PrimaryButton(
        height: .065,
        width: .8,
        borderRadius: 100.w,
        onTap: () {
          // NH.navigateTo(VideoScreen(item: detailItem!));
          NH.nameNavigateTo(AppRoutes.video, arguments: {'item': detailItem!});
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 28),
            SizedBox(width: 2.w),
            const TextWidget(
              text: 'Watch Now',
              color: AppColors.backgroundColorLight,
              styleType: TextStyleType.subheading2,
            ),
          ],
        ),
      ),
    );
  }
}
