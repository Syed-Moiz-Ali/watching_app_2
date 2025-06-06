// ignore_for_file: library Hawkins, library_private_types_in_public_api, use_build_context_synchronously, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/shared/provider/local_auth_provider.dart';
import 'package:watching_app_2/shared/widgets/appbars/app_bar.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';

import '../../core/common/utils/common_utils.dart';
import '../../core/global/globals.dart';
import '../../core/navigation/routes.dart';
import '../../presentation/provider/theme_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  // Core animation controllers
  late AnimationController _pageEnterController;
  late AnimationController _backgroundAnimController;
  late AnimationController _floatingButtonController;
  late AnimationController _floatingMenuController;
  late AnimationController _shimmerController;
  late AnimationController _dialogController;

  // Section controllers
  late List<AnimationController> _sectionControllers;

  // Item controllers - for micro-animations
  late List<List<AnimationController>> _itemControllers;

  // State variables
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  final double _textSize = 1.0;
  int? _hoveredSectionIndex;
  int? _hoveredItemIndex;
  bool _contentFilteringEnabled = false;
  bool _explicitContentWarningEnabled = false;
  bool _incognitoModeEnabled = false;
  bool _ageVerificationEnabled = false;
  int _contentFilterAge = 13; // Default age for content filtering
  List<String> _selectedCategories = ['General', 'Kids']; // Default categories
  // Color _customThemeColor =
  //     AppColors.primaryColor; // Default custom theme color

  // Gradients
  // late List<Color> _backgroundGradient;
  // late List<Color> _accentGradient;

  // Particle positions for background animation
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Load saved preferences
    _loadPreferences();

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

    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

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
    // _updateThemeColors();

    // Start animations with super premium staggered effect
    _pageEnterController.forward();
    _floatingButtonController.forward();

    // Staggered animations for sections and items
    Future.delayed(const Duration(milliseconds: 300), () {
      _animateSectionsSequentially();
    });
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _contentFilteringEnabled =
          prefs.getBool('contentFilteringEnabled') ?? false;
      _explicitContentWarningEnabled =
          prefs.getBool('explicitContentWarningEnabled') ?? false;
      _incognitoModeEnabled = prefs.getBool('incognitoModeEnabled') ?? false;
      _ageVerificationEnabled =
          prefs.getBool('ageVerificationEnabled') ?? false;
      _contentFilterAge = prefs.getInt('contentFilterAge') ?? 13;
      _selectedCategories =
          prefs.getStringList('selectedCategories') ?? ['General', 'Kids'];
    });

    // Apply dark mode to ThemeProvider
    if (_isDarkMode) {
      context.read<ThemeProvider>().setTheme(ThemeMode.dark);
    }
    // Update theme with custom color
    // _updateThemeColors();
  }

  // Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('contentFilteringEnabled', _contentFilteringEnabled);
    await prefs.setBool(
        'explicitContentWarningEnabled', _explicitContentWarningEnabled);
    await prefs.setBool('incognitoModeEnabled', _incognitoModeEnabled);
    await prefs.setBool('ageVerificationEnabled', _ageVerificationEnabled);
    await prefs.setInt('contentFilterAge', _contentFilterAge);
    await prefs.setStringList('selectedCategories', _selectedCategories);
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

  void _updateThemeColors() async {
    var tempColor = context.read<ThemeProvider>().tempColor;
    await SMA.pref!.setInt('customThemeColor', tempColor!.value);

    CommonFunctions.customBottomSheet(
        icon: Icons.restart_alt_rounded,
        title: 'Restart',
        description: 'To Apply Restart the App',
        btnText: 'Restart',
        onTap: () async {
          NH.navigateBack();
          NH.nameNavigateAndRemoveUntil(AppRoutes.splash);

          // await Turf.navigateTo(const SplashScreen());
        });
    // _backgroundGradient = [
    //   _customThemeColor.withOpacity(.5),
    //   Colors.white,
    //   _customThemeColor.withOpacity(.5)
    // ];

    // _accentGradient = [
    //   _customThemeColor,
    //   _customThemeColor.withOpacity(.8),
    //   _customThemeColor.withOpacity(.85)
    // ];
  }

  @override
  void dispose() {
    _pageEnterController.dispose();
    _backgroundAnimController.dispose();
    _floatingButtonController.dispose();
    _floatingMenuController.dispose();
    _shimmerController.dispose();
    _dialogController.dispose();

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
              // _buildAnimatedBackground(),

              // Main content
              Scaffold(
                appBar: _buildAppBar(),
                body: _buildBody(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildAnimatedBackground() {
  //   return AnimatedBuilder(
  //     animation: _backgroundAnimController,
  //     builder: (context, _) {
  //       // Update particle positions
  //       for (final particle in _particles) {
  //         particle.x += particle.speedX;
  //         particle.y += particle.speedY;

  //         // Wrap around edges
  //         if (particle.x < -0.1) particle.x = 1.1;
  //         if (particle.x > 1.1) particle.x = -0.1;
  //         if (particle.y < -0.1) particle.y = 1.1;
  //         if (particle.y > 1.1) particle.y = -0.1;
  //       }

  //       return AnimatedContainer(
  //         duration: const Duration(milliseconds: 500),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             colors: _backgroundGradient,
  //           ),
  //         ),
  //         child: CustomPaint(
  //           painter: _ParticlePainter(
  //             particles: _particles,
  //             color: AppColors.primaryColor,
  //             animationValue: _backgroundAnimController.value,
  //           ),
  //           child: const SizedBox.expand(),
  //         ),
  //       );
  //     },
  //   );
  // }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      elevation: 0,
      title: "Settings",
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
            icon: const Icon(Icons.search),
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
                      _savePreferences();
                    });
                  },
                  type: _SettingType.toggle,
                ),
                _SettingItem(
                  title: 'Custom Theme',
                  subtitle: 'Choose a custom color theme for the app',
                  icon: Icons.color_lens,
                  onTap: () {
                    _openCustomThemeDialog();
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
                      _savePreferences();
                    });
                  },
                  type: _SettingType.toggle,
                ),
              ],
            ),

            // Content Preferences Section
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
                    _openCategoryFilterDialog();
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
                  value: context.read<LocalAuthProvider>().isProtectionEnabled,
                  onChanged: (value) {
                    context.read<LocalAuthProvider>().toggleProtection(value);
                    _savePreferences();
                  },
                  type: _SettingType.toggle,
                ),
                _SettingItem(
                  title: 'Backup',
                  subtitle: 'Backup your data',
                  icon: Icons.backup,
                  onTap: () {
                    // BackupService().createBackup();
                  },
                  type: _SettingType.button,
                ),
                _SettingItem(
                  title: 'Restore',
                  subtitle: 'Restore your data',
                  icon: Icons.backup,
                  onTap: () {
                    // BackupService().restoreBackup();
                  },
                  type: _SettingType.button,
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
                  onTap: () {
                    _openContentFilterDialog();
                  },
                  type: _SettingType.button,
                ),
                _SettingItem(
                  title: 'Explicit Content Warning',
                  subtitle: 'Show a warning before displaying explicit content',
                  icon: Icons.warning,
                  value: _explicitContentWarningEnabled,
                  onChanged: (value) {
                    setState(() {
                      _explicitContentWarningEnabled = value;
                      _savePreferences();
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
                      _savePreferences();
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
                      _savePreferences();
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

  void _openContentFilterDialog() {
    _dialogController.reset();
    _dialogController.forward();

    showDialog(
      context: context,
      builder: (context) {
        int tempAge = _contentFilterAge;

        return AnimatedBuilder(
          animation: _dialogController,
          builder: (context, _) {
            return ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
                parent: _dialogController,
                curve: Curves.easeOutBack,
              )),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Content Age Filter',
                        color: Colors.white,
                        fontSize: 18.sp * _textSize,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'Select minimum age for content filtering',
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp * _textSize,
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<int>(
                        value: tempAge,
                        dropdownColor: AppColors.primaryColor.withOpacity(0.9),
                        items: [13, 16, 18, 21].map((age) {
                          return DropdownMenuItem(
                            value: age,
                            child: TextWidget(
                              text: '$age+',
                              color: Colors.white,
                              fontSize: 14.sp * _textSize,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              tempAge = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: TextWidget(
                              text: 'Cancel',
                              color: Colors.white,
                              fontSize: 15.sp * _textSize,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            onTap: () {
                              setState(() {
                                _contentFilteringEnabled = true;
                                _contentFilterAge = tempAge;
                                _savePreferences();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCategoryFilterDialog() {
    _dialogController.reset();
    _dialogController.forward();

    List<String> tempCategories = List.from(_selectedCategories);
    const availableCategories = [
      'General',
      'Kids',
      'Teens',
      'Adults',
      'Educational',
      'Entertainment',
      'News',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AnimatedBuilder(
          animation: _dialogController,
          builder: (context, _) {
            return ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
                parent: _dialogController,
                curve: Curves.easeOutBack,
              )),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Content Categories',
                        color: Colors.white,
                        fontSize: 18.sp * _textSize,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'Select preferred content categories',
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp * _textSize,
                      ),
                      const SizedBox(height: 16),
                      ...availableCategories.map((category) {
                        return CheckboxListTile(
                          title: TextWidget(
                            text: category,
                            color: Colors.white,
                            fontSize: 14.sp * _textSize,
                          ),
                          value: tempCategories.contains(category),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                tempCategories.add(category);
                              } else {
                                tempCategories.remove(category);
                              }
                            });
                          },
                          checkColor: Colors.white,
                          activeColor: AppColors.primaryColor,
                        );
                      }),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: TextWidget(
                              text: 'Cancel',
                              color: Colors.white,
                              fontSize: 15.sp * _textSize,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            onTap: () {
                              setState(() {
                                _selectedCategories = tempCategories;
                                _savePreferences();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCustomThemeDialog() {
    _dialogController.reset();
    _dialogController.forward();

    // Color tempColor = _customThemeColor;

    showDialog(
      context: context,
      builder: (context) {
        return AnimatedBuilder(
          animation: _dialogController,
          builder: (context, _) {
            return ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
                parent: _dialogController,
                curve: Curves.easeOutBack,
              )),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor.withOpacity(.7),
                        AppColors.primaryColor.withOpacity(.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Custom Theme Color',
                        color: Colors.white,
                        fontSize: 18.sp * _textSize,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'Select a custom theme color',
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp * _textSize,
                      ),
                      const SizedBox(height: 16),
                      // Simple color picker using buttons
                      Consumer<ThemeProvider>(builder: (context, provider, _) {
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Colors.red,
                            Colors.blue,
                            Colors.green,
                            Colors.purple,
                            Colors.orange,
                            Colors.teal,
                            Colors.pink,
                          ].map((color) {
                            return GestureDetector(
                              onTap: () {
                                provider.setTempColor(color);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: provider.tempColor == color
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: TextWidget(
                              text: 'Cancel',
                              color: Colors.white,
                              fontSize: 15.sp * _textSize,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            onTap: () {
                              setState(() {
                                _savePreferences();
                              });
                              _updateThemeColors();
                              // Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
                          color: isHovered
                              ? AppColors.primaryColor
                              : Colors.transparent,
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
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            // color: AppColors.primaryColor,
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
                      ? AppColors.primaryColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isHovered ? 12 : 8,
                  offset: isHovered ? const Offset(0, 4) : const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: isHovered
                    ? AppColors.primaryColor
                    : Colors.grey.shade300.withOpacity(0.5),
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
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.2),
                    value,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1 * value),
                blurRadius: 8 * value,
                spreadRadius: 2 * value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 1.0 + (0.1 * value),
            child: Icon(
              icon,
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
          final safeAnimationValue = animationValue.clamp(0.0, 1.0);

          return Container(
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: value
                  ? AppColors.primaryColor.withOpacity(0.9)
                  : AppColors.disabledColor,
              boxShadow: [
                BoxShadow(
                  color: value
                      ? AppColors.primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 2 + (animationValue * 24),
                  top: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value
                          ? AppColors.backgroundColorLight.withOpacity(0.4)
                          : AppColors.greyColor,
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
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(.7)
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
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
