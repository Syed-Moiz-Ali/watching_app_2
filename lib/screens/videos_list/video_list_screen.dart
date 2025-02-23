// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:watching_app_2/core/enums/app_enums.dart';
import 'package:watching_app_2/core/navigation/navigator.dart';
import 'package:watching_app_2/widgets/custom_appbar.dart';
import 'package:watching_app_2/widgets/loading_indicator.dart';

import '../../core/constants/color_constants.dart';
import '../../core/global/app_global.dart';
import '../../models/content_item.dart';
import '../../models/content_source.dart';
import '../../services/scrapers/scraper_service.dart';
import '../../widgets/custom_floatingaction_button.dart';
import '../../widgets/text_widget.dart';
import '../detail_screen/detail_screen.dart';
import 'components/query_bottomsheet.dart';
import 'components/video_grid_view.dart';

class VideoListScreen extends StatefulWidget {
  final ContentSource source;

  const VideoListScreen({super.key, required this.source});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late ScraperService scraperService;
  List<ContentItem> videos = [];
  bool isLoading = true;
  String? error;
  int _currentPlayingIndex = -1;
  bool isGrid = false;

  @override
  void initState() {
    super.initState();
    scraperService = ScraperService(widget.source);
    loadVideos();
  }

  Future<void> loadVideos({String? selectedQuery}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final newVideos = await scraperService.getContent(
          selectedQuery ?? widget.source.query.entries.first.value, 1);
      setState(() {
        videos = newVideos.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load videos: $e';
        isLoading = false;
      });
    }
  }

  Future<void> searhVideos(String value) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final newVideos = await scraperService.search(value, 1);
      setState(() {
        videos = newVideos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load videos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: widget.source.name,
        isShowSearchbar: true,
        onSearch: (value) {
          searhVideos(value);
        },
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: loadVideos,
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CustomLoadingIndicator())
              : error != null
                  ? Center(child: Text(error!))
                  : videos.isEmpty
                      ? const Center(
                          child: TextWidget(
                            text: 'No data found',
                            styleType: TextStyleType.subheading,
                          ),
                        )
                      : VideoGridView(
                          videos: videos,
                          isGrid: isGrid,
                          currentPlayingIndex: _currentPlayingIndex,
                          onItemTap: (index) {
                            NH.navigateTo(DetailScreen(item: videos[index]));
                          },
                          onHorizontalDragStart: (index) => setState(() {
                            _currentPlayingIndex = index;
                          }),
                          onHorizontalDragEnd: (index) => setState(() {
                            _currentPlayingIndex = index;
                          }),
                        ),
          _buildToggleButton(),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        source: widget.source,
        onSelected: (query) => loadVideos(selectedQuery: query),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      bottom: 10,
      left: 20,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(1000),
        ),
        child: IconButton(
          icon: Icon(
            isGrid ? Icons.list : Icons.grid_view,
            color: AppColors.backgroundColorLight,
          ),
          onPressed: () => setState(() => isGrid = !isGrid),
        ),
      ),
    );
  }
}
