import 'package:flutter/material.dart';
import 'animated_searchbar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimController;
  List<String> _searchResults = [];
  bool _isFilterActive = false;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        // Mock search results - replace with your actual search logic
        _searchResults = [
          'Result for "$query" - Item 1',
          'Result for "$query" - Item 2',
          'Result for "$query" - Item 3',
          'Result for "$query" - Item 4',
        ];
      }
    });
  }

  void _toggleFilter() {
    setState(() {
      _isFilterActive = !_isFilterActive;
      // Show a snackbar to indicate filter toggle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isFilterActive ? 'Filters applied' : 'Filters removed'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1a2a6c),
                      Color(0xFFb21f1f),
                      Color(0xFFfdbb2d),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      _bgAnimController.value,
                      (_bgAnimController.value + 0.3) % 1.0,
                      (_bgAnimController.value + 0.6) % 1.0,
                    ],
                  ),
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Custom animated search bar
                AnimatedSearchBar(
                  primaryColor: const Color(0xFF6C63FF),
                  hintText: 'Search for anything...',
                  onSearch: _handleSearch,
                  onFilterTap: _toggleFilter,
                ),

                // Search results
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _searchResults.isEmpty
                        ? _buildInitialContent()
                        : _buildSearchResults(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 120,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'Type to start searching',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        // Animation delay based on index
        final delay = index * 0.2;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            // Delayed entrance for each item
            final opacity = (value - delay).clamp(0.0, 1.0);
            final yOffset = 50 * (1 - opacity);

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C63FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    _searchResults[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
}
