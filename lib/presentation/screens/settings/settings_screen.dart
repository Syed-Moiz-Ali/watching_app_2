// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';

import '../../provider/theme_provider.dart';

class PremiumSettingsScreen extends StatefulWidget {
  const PremiumSettingsScreen({super.key});

  @override
  _PremiumSettingsScreenState createState() => _PremiumSettingsScreenState();
}

class _PremiumSettingsScreenState extends State<PremiumSettingsScreen>
    with TickerProviderStateMixin {
  // Core animation controllers
  late AnimationController _pageEnterController;
  late AnimationController _backgroundAnimController;
  late AnimationController _floatingButtonController;
  late AnimationController _floatingMenuController;
  late AnimationController _shimmerController;

  // Section controllers
  late List<AnimationController> _sectionControllers;

  // Item controllers - for micro-animations
  late List<List<AnimationController>> _itemControllers;

  // State variables
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = true;
  bool _biometricAuthEnabled = false;
  final double _textSize = 1.0;
  int? _hoveredSectionIndex;
  int? _hoveredItemIndex;
  bool _contentFilteringEnabled = false;
  bool _explicitContentWarningEnabled = false;
  bool _incognitoModeEnabled = false;
  bool _ageVerificationEnabled = false;

  // Colors for theme
  late Color _primaryColor;
  late Color _cardColor;
  late Color _iconColor;
  late Color _dividerColor;

  // Gradients
  late List<Color> _backgroundGradient;
  late List<Color> _accentGradient;

  // Particle positions for background animation
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Create particles for background effect
    _createParticles();

    // Initialize main controllers
    _pageEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat();

    _floatingButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _floatingMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Initialize section controllers
    const sectionCount = 5;
    _sectionControllers = List.generate(
      sectionCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + (index * 150)),
      ),
    );

    // Initialize item controllers (nested for each section)
    _itemControllers = List.generate(
      sectionCount,
      (sectionIndex) => List.generate(
        4, // Max items per section
        (itemIndex) => AnimationController(
          vsync: this,
          duration: Duration(
              milliseconds: 300 + ((sectionIndex * 4 + itemIndex) * 50)),
        ),
      ),
    );

    // Set initial theme
    _updateThemeColors();

    // Start animations with super premium staggered effect
    _pageEnterController.forward();
    _floatingButtonController.forward();

    // Staggered animations for sections and items
    Future.delayed(const Duration(milliseconds: 300), () {
      _animateSectionsSequentially();
    });
  }

  void _createParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _Particle(
          x: random.nextDouble() * 1.2 - 0.1,
          y: random.nextDouble() * 1.2 - 0.1,
          size: random.nextDouble() * 8 + 2,
          speedX: (random.nextDouble() - 0.5) * 0.0002,
          speedY: (random.nextDouble() - 0.5) * 0.0002,
          opacity: random.nextDouble() * 0.5 + 0.1,
        ),
      );
    }
  }

  void _animateSectionsSequentially() {
    for (int i = 0; i < _sectionControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 150 * i), () {
        _sectionControllers[i].forward();

        // Animate items within this section
        for (int j = 0; j < _itemControllers[i].length; j++) {
          Future.delayed(Duration(milliseconds: 100 + (j * 80)), () {
            _itemControllers[i][j].forward();
          });
        }
      });
    }
  }

  void _updateThemeColors() {
    _primaryColor = AppColors.primaryColor;

    _cardColor = AppColors.backgroundColorLight;

    _iconColor = AppColors.secondaryColor;
    _dividerColor = Colors.grey.shade300;

    _backgroundGradient = [
      AppColors.backgroundColorLight.withOpacity(.5),
      Colors.white,
      AppColors.backgroundColorLight.withOpacity(.5)
    ];

    _accentGradient = [
      AppColors.primaryColor,
      AppColors.primaryColor.withOpacity(.8),
      AppColors.primaryColor.withOpacity(.85)
    ];
  }

  @override
  void dispose() {
    _pageEnterController.dispose();
    _backgroundAnimController.dispose();
    _floatingButtonController.dispose();
    _floatingMenuController.dispose();
    _shimmerController.dispose();

    for (final controller in _sectionControllers) {
      controller.dispose();
    }

    for (final section in _itemControllers) {
      for (final controller in section) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_pageEnterController, _backgroundAnimController]),
      builder: (context, _) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Animated background
              _buildAnimatedBackground(),

              // Main content
              Scaffold(
                // backgroundColor: Colors.transparent,
                // extendBodyBehindAppBar: true,
                appBar: _buildAppBar(),
                body: _buildBody(),
                // floatingActionButton: _buildFloatingActionButton(),
              ),

              // Floating menu
              // _buildFloatingMenu(),

              // Premium floating badge
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimController,
      builder: (context, _) {
        // Update particle positions
        for (final particle in _particles) {
          particle.x += particle.speedX;
          particle.y += particle.speedY;

          // Wrap around edges
          if (particle.x < -0.1) particle.x = 1.1;
          if (particle.x > 1.1) particle.x = -0.1;
          if (particle.y < -0.1) particle.y = 1.1;
          if (particle.y > 1.1) particle.y = -0.1;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _backgroundGradient,
            ),
          ),
          child: CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              color: _primaryColor,
              animationValue: _backgroundAnimController.value,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titleScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageEnterController,
      curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
    ));

    final titleFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageEnterController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
    ));

    return AppBar(
      elevation: 0,
      // backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: _primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          ScaleTransition(
            scale: titleScale,
            child: FadeTransition(
              opacity: titleFade,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: (1 - value) * 0.5,
                    child: Icon(
                      Icons.settings,
                      color: _primaryColor,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          ScaleTransition(
            scale: titleScale,
            child: FadeTransition(
              opacity: titleFade,
              child: TextWidget(
                text: 'Settings',
                fontWeight: FontWeight.bold,
                fontSize: 22.sp * _textSize,
                // color: _textColor,
              ),
            ),
          ),
        ],
      ),
      actions: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _pageEnterController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutQuint),
          )),
          child: IconButton(
            icon: Icon(Icons.search, color: _iconColor),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 30),

            // Appearance Section
            _buildSectionWithItems(
              sectionIndex: 0,
              title: 'Appearance',
              icon: Icons.palette,
              items: [
                _SettingItem(
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark themes',
                  icon: Icons.dark_mode,
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                      context
                          .read<ThemeProvider>()
                          .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                      // _updateThemeColors();
                    });
                  },
                  type: _SettingType.toggle,
                ),
                _SettingItem(
                  title: 'Custom Theme',
                  subtitle: 'Choose a custom color theme for the app',
                  icon: Icons.color_lens,
                  onTap: () {
                    // Open a color picker dialog for custom themes
                    // _openCustomThemeDialog();
                  },
                  type: _SettingType.button,
                ),
              ],
            ),

            // Notifications Section
            _buildSectionWithItems(
              sectionIndex: 1,
              title: 'Notifications',
              icon: Icons.notifications,
              items: [
                _SettingItem(
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts and updates on your device',
                  icon: Icons.notifications_active,
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  type: _SettingType.toggle,
                ),
              ],
            ),
            _buildSectionWithItems(
              sectionIndex: 2,
              title: 'Content Preferences',
              icon: Icons.category,
              items: [
                _SettingItem(
                  title: 'Content Categories',
                  subtitle: 'Filter content by preferred categories',
                  icon: Icons.filter_list,
                  onTap: () {
                    // Implement category selection screen
                    // _openCategoryFilterDialog();
                  },
                  type: _SettingType.button,
                ),
              ],
            ),
            // Security Section
            _buildSectionWithItems(
              sectionIndex: 3,
              title: 'Security & Privacy',
              icon: Icons.security,
              items: [
                _SettingItem(
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face to unlock',
                  icon: Icons.fingerprint,
                  value: _biometricAuthEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricAuthEnabled = value;
                    });
                  },
                  type: _SettingType.toggle,
                ),
                _SettingItem(
                  title: 'Auto Backup',
                  subtitle: 'Automatically backup your data',
                  icon: Icons.backup,
                  value: _autoBackupEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoBackupEnabled = value;
                    });
                  },
                  type: _SettingType.toggle,
                ),
              ],
            ),

            // Adult Content Preferences Section
            _buildSectionWithItems(
              sectionIndex: 4,
              title: 'Adult Content Preferences',
              icon: Icons.category,
              items: [
                _SettingItem(
                  title: 'Content Filtering',
                  subtitle: 'Set content preferences based on age or category',
                  icon: Icons.filter_list,
                  value: _contentFilteringEnabled,
                  onChanged: (value) {
                    setState(() {
                      _contentFilteringEnabled = value;
                    });
                  },
                  type: _SettingType.toggle,
                ),
                _SettingItem(
                  title: 'Explicit Content Warning',
                  subtitle: 'Show a warning before displaying explicit content',
                  icon: Icons.warning,
                  value: _explicitContentWarningEnabled,
                  onChanged: (value) {
                    setState(() {
                      _explicitContentWarningEnabled = value;
                    });
                  },
                  type: _SettingType.toggle,
                ),
                _SettingItem(
                  title: 'Incognito Mode',
                  subtitle: 'Browse privately without saving activity',
                  icon: Icons.visibility_off,
                  value: _incognitoModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _incognitoModeEnabled = value;
                    });
                  },
                  type: _SettingType.toggle,
                ),
                _SettingItem(
                  title: 'Age Verification',
                  subtitle: 'Enable age verification for restricted content',
                  icon: Icons.account_circle,
                  value: _ageVerificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _ageVerificationEnabled = value;
                    });
                  },
                  type: _SettingType.toggle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final animation = CurvedAnimation(
      parent: _pageEnterController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
    );

    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.0).animate(animation),
      child: FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _accentGradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated shimmer effect
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        width: constraints.maxWidth,
                        height: 20.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment(
                                -1.0 + _shimmerController.value * 2, 0),
                            end: Alignment(
                                -0.5 + _shimmerController.value * 2, 1),
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      TextWidget(
                        text: 'Welcome to Premium',
                        color: Colors.white,
                        fontSize: 18.sp * _textSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextWidget(
                    text:
                        'Enjoy exclusive premium features, advanced animations, and a truly luxurious experience.',
                    color: Colors.white.withOpacity(0.9),
                    maxLine: 4,
                    fontSize: 14.sp * _textSize,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          // backgroundColor: Colors.white.withOpacity(0.25),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            TextWidget(
                              text: 'Explore Premium',
                              color: Colors.white,
                              fontSize: 15.sp * _textSize,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 17.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionWithItems({
    required int sectionIndex,
    required String title,
    required IconData icon,
    required List<_SettingItem> items,
  }) {
    final isHovered = _hoveredSectionIndex == sectionIndex;
    final sectionAnimation = CurvedAnimation(
      parent: _sectionControllers[sectionIndex],
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSectionIndex = sectionIndex),
      onExit: (_) => setState(() => _hoveredSectionIndex = null),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(sectionAnimation),
          child: FadeTransition(
            opacity: sectionAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isHovered ? _primaryColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            // color: _primaryColor,
                            size: 22.sp,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextWidget(
                          text: title,
                          fontSize: 20.sp * _textSize,
                          fontWeight: FontWeight.bold,
                          // color: _textColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Section Items
                ...List.generate(items.length, (itemIndex) {
                  return _buildSettingItem(
                    item: items[itemIndex],
                    sectionIndex: sectionIndex,
                    itemIndex: itemIndex,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required _SettingItem item,
    required int sectionIndex,
    required int itemIndex,
  }) {
    final isHovered =
        _hoveredItemIndex == itemIndex && _hoveredSectionIndex == sectionIndex;
    final itemAnimation = CurvedAnimation(
      parent: _itemControllers[sectionIndex][itemIndex],
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart),
    );

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
          .animate(itemAnimation),
      child: FadeTransition(
        opacity: itemAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() {
            _hoveredSectionIndex = sectionIndex;
            _hoveredItemIndex = itemIndex;
          }),
          onExit: (_) => setState(() {
            _hoveredItemIndex = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: isHovered
              //       ? [_cardColor, _cardColor.withOpacity(0.8)]
              //       : _cardGradient,
              // ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? _primaryColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isHovered ? 12 : 8,
                  offset: isHovered ? const Offset(0, 4) : const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color:
                    isHovered ? _primaryColor : _dividerColor.withOpacity(0.5),
                width: isHovered ? 1.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildAnimatedItemIcon(item.icon, isHovered),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: item.title,
                              fontSize: 17.sp * _textSize,
                              fontWeight: FontWeight.bold,
                              // color: _textColor,
                            ),
                            if (item.subtitle != null)
                              const SizedBox(height: 4),
                            if (item.subtitle != null)
                              TextWidget(
                                text: item.subtitle!,
                                fontSize: 14.sp * _textSize,
                                maxLine: 4,
                                // color: _textColor.withOpacity(0.7),
                              ),
                          ],
                        ),
                      ),
                      if (item.type == _SettingType.toggle)
                        _buildSuperPremiumSwitch(
                            value: item.value as bool,
                            onChanged: item.onChanged),
                      if (item.type == _SettingType.button)
                        _buildActionButton(onTap: item.onTap!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItemIcon(IconData icon, bool isHovered) {
    var isDarkMode = context.watch<ThemeProvider>();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isHovered ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: isDarkMode.isDarkTheme
                ? Color.lerp(
                    AppColors.backgroundColorLight.withOpacity(0.1),
                    AppColors.backgroundColorLight.withOpacity(0.2),
                    value,
                  )
                : Color.lerp(
                    _primaryColor.withOpacity(0.1),
                    _primaryColor.withOpacity(0.2),
                    value,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.1 * value),
                blurRadius: 8 * value,
                spreadRadius: 2 * value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 1.0 + (0.1 * value),
            child: Icon(
              icon,
              // color: !isDarkMode.isDarkTheme
              //     ? AppColors.backgroundColorLight
              //     : _primaryColor,
              size: 20.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuperPremiumSwitch({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value ? 1 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, animationValue, _) {
          // Ensure animation value is within valid range
          final safeAnimationValue = animationValue.clamp(0.0, 1.0);

          return Container(
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.disabledColor,
              boxShadow: [
                BoxShadow(
                  color: value
                      ? _primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Track highlights
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: (1 - safeAnimationValue).clamp(0.0, 1.0),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // color: _textColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: safeAnimationValue.clamp(0.0, 1.0),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: 2 + (animationValue * 24),
                  top: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greyColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        value ? Icons.check : Icons.close,
                        size: 14,
                        color: AppColors.backgroundColorLight,
                        // color:
                        //     value ? _primaryColor : _textColor.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _accentGradient,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextWidget(
          text: 'Execute',
          color: Colors.white,
          fontSize: 15.sp * _textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double animationValue;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = color.withOpacity(
          particle.opacity *
              (0.5 + 0.5 * math.sin(animationValue * math.pi * 2)),
        );

      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );

      // Draw connecting lines between nearby particles
      for (final otherParticle in particles) {
        final dx = (particle.x - otherParticle.x).abs() * size.width;
        final dy = (particle.y - otherParticle.y).abs() * size.height;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < 100) {
          final linePaint = Paint()
            ..color = color.withOpacity(
              0.05 *
                  (1 - distance / 100) *
                  (0.5 +
                      0.5 *
                          math.sin(
                              (animationValue + particle.x) * math.pi * 2)),
            )
            ..strokeWidth = 1.0;

          canvas.drawLine(
            Offset(
              particle.x * size.width,
              particle.y * size.height,
            ),
            Offset(
              otherParticle.x * size.width,
              otherParticle.y * size.height,
            ),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

enum _SettingType {
  toggle,

  button,
}

class _SettingItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final dynamic value;
  final Function(dynamic) onChanged;
  final VoidCallback? onTap;
  final _SettingType type;

  _SettingItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.value,
    required this.type,
    Function(dynamic)? onChanged,
    this.onTap,
  }) : onChanged = onChanged ?? ((value) {});
}
