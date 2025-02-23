// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/models/content_source.dart';
import 'package:watching_app_2/widgets/custom_appbar.dart';
import '../../services/source_manager.dart';
import '../../widgets/custom_tabbar.dart';

import '../../widgets/loading_indicator.dart';
import 'components/content_list.dart';

class SourceListScreen extends StatefulWidget {
  const SourceListScreen({super.key});

  @override
  _SourceListScreenState createState() => _SourceListScreenState();
}

class _SourceListScreenState extends State<SourceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SourceManager sourceManager = SourceManager();
  bool isLoading = true;
  List<ContentSource> sources = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    loadSources("videos"); // Load default tab (videos)
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    switch (_tabController.index) {
      case 0:
        loadSources("videos");
        break;
      case 1:
        loadSources("tiktok");
        break;
      case 2:
        loadSources("photos");
        break;
      case 3:
        loadSources("manga");
        break;
    }
  }

  Future<void> loadSources(String category) async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final loadedSources = await sourceManager.loadSources(category);
    setState(() {
      sources = loadedSources;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        appBarHeight: 15.h,
        elevation: 0,
        title: 'Content Sources',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: CustomTabBar(
            tabController: _tabController,
            onTabChanged: (index) {
              // This is already handled by the listener
            },
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CustomLoadingIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) {
                return ContentList(
                  sources: sources,
                );
              }),
            ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}
