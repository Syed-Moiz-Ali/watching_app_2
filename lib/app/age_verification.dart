import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/shared/widgets/misc/icon.dart';

import '../shared/widgets/misc/text_widget.dart';

class AgeVerificationScreen extends StatefulWidget {
  const AgeVerificationScreen({super.key});

  @override
  State<AgeVerificationScreen> createState() => _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends State<AgeVerificationScreen> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _showInputFields = false;
  bool _isVerified = false;
  int _currentStep = 0; // 0: age, 1: name, 2: location permission

  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();

  String? _locationInfo;
  Map<String, dynamic>? _deviceInfo;

  @override
  void initState() {
    super.initState();
    // Show input fields after initial animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showInputFields = true;
        });
      }
    });
    _getDeviceInfo();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _nameController.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          'platform': 'Android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'brand': androidInfo.brand,
          'appVersion': packageInfo.version,
        };
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'brand': 'Apple',
          'appVersion': packageInfo.version,
        };
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
  }

  Future<void> _verifyAge() async {
    if (_dayController.text.isEmpty ||
        _monthController.text.isEmpty ||
        _yearController.text.isEmpty) {
      _showErrorSnackbar('Please enter your complete birth date');
      return;
    }

    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    if (day == null ||
        month == null ||
        year == null ||
        day < 1 ||
        day > 31 ||
        month < 1 ||
        month > 12 ||
        year < 1900) {
      _showErrorSnackbar('Please enter a valid date');
      return;
    }

    try {
      _selectedDate = DateTime(year, month, day);
    } catch (e) {
      _showErrorSnackbar('Invalid date format');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final age = _calculateAge(_selectedDate!);

    if (age >= 18) {
      setState(() {
        _isLoading = false;
        _currentStep = 1; // Move to name input
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _showAgeRestrictionDialog();
    }
  }

  Future<void> _collectName() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter what we should call you');
      return;
    }

    setState(() {
      _currentStep = 2; // Move to location permission
    });
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        );
        _locationInfo =
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      } else {
        _locationInfo = 'Permission denied';
      }
    } catch (e) {
      _locationInfo = 'Unable to get location';
    }

    await _saveUserData();
    await _sendAnalytics();

    // Print user, analytics, and location details
    // Create a user details map
    Map<String, dynamic> userDetails = {
      'name': _nameController.text.trim(),
      'birth_date': _selectedDate != null
          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
          : 'N/A',
      'location_info': _locationInfo,
      'device_info': _deviceInfo,
      'user_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'registration_time': DateTime.now().toIso8601String(),
      'age_range': _calculateAgeRange(_calculateAge(_selectedDate!)),
      'app_version': _deviceInfo?['appVersion'],
    };

    // Store user details as JSON string in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_details', userDetails.toString());

    print('User Details: $userDetails');

    setState(() {
      _isLoading = false;
      _isVerified = true;
    });

    // Navigate to main app after success animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        NH.nameNavigateAndRemoveUntil(AppRoutes.splash);
      }
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save user data locally
    await prefs.setBool('age_verified', true);
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('birth_date',
        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}');
    await prefs.setString('location_info', _locationInfo ?? 'Not available');
    await prefs.setString('device_info', _deviceInfo.toString());
    await prefs.setString(
        'registration_date', DateTime.now().toIso8601String());
  }

  Future<void> _sendAnalytics() async {
    // This is where you would send analytics data to your server
    // For now, we'll just increment local active user counter
    final prefs = await SharedPreferences.getInstance();
    int activeUsers = prefs.getInt('active_users_count') ?? 0;
    await prefs.setInt('active_users_count', activeUsers + 1);

    // In a real app, you would send this data to your analytics service:
    Map<String, dynamic> analyticsData = {
      'user_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'registration_time': DateTime.now().toIso8601String(),
      'location': _locationInfo,
      'device_info': _deviceInfo,
      'age_range': _calculateAgeRange(_calculateAge(_selectedDate!)),
      'app_version': _deviceInfo?['appVersion'],
    };

    print(
        'Analytics Data: $analyticsData'); // In production, send to your server
  }

  String _calculateAgeRange(int age) {
    if (age >= 18 && age <= 25) return '18-25';
    if (age >= 26 && age <= 35) return '26-35';
    if (age >= 36 && age <= 45) return '36-45';
    if (age >= 46 && age <= 55) return '46-55';
    return '55+';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showErrorSnackbar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(text: message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _showAgeRestrictionDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            TextWidget(
              text: 'Age Restriction',
              fontSize: 18.sp,
            ),
          ],
        ),
        content: const TextWidget(
          text: 'You must be 18 years or older to use this application. '
              'This app contains adult content that is not suitable for minors.',
        ),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const TextWidget(text: 'Exit App'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 300.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.blue, size: 6.w),
              SizedBox(width: 3.w),
              Expanded(
                child: TextWidget(
                  text: 'Privacy Notice',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          TextWidget(
            text: '🔒 All your data is stored locally on your device\n'
                '🚫 We don\'t store any personal information in our database\n'
                '📊 Only anonymous usage statistics are collected\n'
                '🔐 Your privacy and security are our top priority',
            fontSize: 13.sp,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // App Logo/Icon
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2),
                  ),
                  child: const ClipOval(
                    child: CustomIconWidget(
                      imageUrl: 'assets/images/icon.png',
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 600.ms,
                        curve: Curves.elasticOut)
                    .shimmer(
                        duration: 2000.ms,
                        color: Colors.black.withOpacity(0.3)),

                SizedBox(height: 6.h),

                // Title
                TextWidget(
                  text: _currentStep == 0
                      ? 'Age Verification'
                      : _currentStep == 1
                          ? 'What should we call you?'
                          : 'Final Step',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(
                    begin: 0.3, duration: 600.ms, curve: Curves.easeOut),

                SizedBox(height: 2.h),

                // Subtitle
                TextWidget(
                  text: _currentStep == 0
                      ? 'This app contains adult content.\nPlease verify you are 18 or older.'
                      : _currentStep == 1
                          ? 'Help us personalize your experience'
                          : 'Allow location access for better content recommendations',
                  textAlign: TextAlign.center,
                  fontSize: 16.sp,
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(
                    begin: 0.2, duration: 600.ms, curve: Curves.easeOut),

                // Privacy Note
                if (_showInputFields && !_isVerified) _buildPrivacyNote(),

                SizedBox(height: 4.h),

                // Step 0: Age Verification
                if (_showInputFields && !_isVerified && _currentStep == 0)
                  _buildAgeVerificationStep(),

                // Step 1: Name Input
                if (_showInputFields && !_isVerified && _currentStep == 1)
                  _buildNameInputStep(),

                // Step 2: Location Permission
                if (_showInputFields && !_isVerified && _currentStep == 2)
                  _buildLocationPermissionStep(),

                // Success State
                if (_isVerified) _buildSuccessState(),

                SizedBox(height: 8.h),

                // Footer
                TextWidget(
                  text: 'Your privacy is important to us.\n'
                      'This information is stored locally on your device only.',
                  textAlign: TextAlign.center,
                  fontSize: 12.sp,
                ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeVerificationStep() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextWidget(
            text: 'Enter your birth date',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDateField(
                controller: _dayController,
                focusNode: _dayFocus,
                hint: 'DD',
                maxLength: 2,
                nextFocus: _monthFocus,
              ),
              TextWidget(
                text: '/',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              _buildDateField(
                controller: _monthController,
                focusNode: _monthFocus,
                hint: 'MM',
                maxLength: 2,
                nextFocus: _yearFocus,
              ),
              TextWidget(
                text: '/',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              _buildDateField(
                controller: _yearController,
                focusNode: _yearFocus,
                hint: 'YYYY',
                maxLength: 4,
                isLast: true,
              ),
            ],
          ),
          SizedBox(height: 5.h),
          PrimaryButton(
            borderRadius: 50.w,
            onTap: _isLoading ? () {} : _verifyAge,
            child: _isLoading
                ? SizedBox(
                    width: 6.w,
                    height: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColorLight,
                      ),
                    ),
                  )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 1000.ms)
                : TextWidget(
                    text: 'Verify Age',
                    fontSize: 18.sp,
                    color: AppColors.backgroundColorLight,
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, duration: 800.ms, curve: Curves.elasticOut)
        .scale(begin: const Offset(0.9, 0.9), duration: 600.ms);
  }

  Widget _buildNameInputStep() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextWidget(
            text: 'What should we call you?',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textAlign: TextAlign.center,
              style: SMA.baseTextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name or nickname',
                hintStyle: SMA.baseTextStyle(),
                border: InputBorder.none,
              ),
              onTap: () => HapticFeedback.selectionClick(),
            ),
          ),
          SizedBox(height: 5.h),
          PrimaryButton(
            borderRadius: 50.w,
            onTap: _collectName,
            child: TextWidget(
              text: 'Continue',
              fontSize: 18.sp,
              color: AppColors.backgroundColorLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, duration: 800.ms, curve: Curves.elasticOut)
        .scale(begin: const Offset(0.9, 0.9), duration: 600.ms);
  }

  Widget _buildLocationPermissionStep() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_on,
            size: 15.w,
            color: Colors.blue,
          ).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms),
          SizedBox(height: 3.h),
          TextWidget(
            text: 'Location Access',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 2.h),
          TextWidget(
            text:
                'This helps us provide better content recommendations and analytics.',
            fontSize: 14.sp,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5.h),
          PrimaryButton(
            borderRadius: 50.w,
            onTap: _isLoading ? () {} : _requestLocationPermission,
            child: _isLoading
                ? SizedBox(
                    width: 6.w,
                    height: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColorLight,
                      ),
                    ),
                  )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 1000.ms)
                : TextWidget(
                    text: 'Allow Location',
                    fontSize: 18.sp,
                    color: AppColors.backgroundColorLight,
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, duration: 800.ms, curve: Curves.elasticOut)
        .scale(begin: const Offset(0.9, 0.9), duration: 600.ms);
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withOpacity(0.2),
            border: Border.all(color: Colors.green, width: 3),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 12.w,
            color: Colors.green,
          ),
        )
            .animate()
            .scale(
                begin: const Offset(0.5, 0.5),
                duration: 600.ms,
                curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1000.ms, color: Colors.green.withOpacity(0.3)),
        SizedBox(height: 4.h),
        TextWidget(
          text: 'Welcome ${_nameController.text.trim()}!',
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: 0.2, duration: 500.ms),
        SizedBox(height: 2.h),
        TextWidget(
          text: 'Setup completed successfully!',
          fontSize: 18.sp,
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required int maxLength,
    FocusNode? nextFocus,
    bool isLast = false,
  }) {
    return Container(
      width: 20.w,
      height: 14.w,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        style: SMA.baseTextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: SMA.baseTextStyle(),
          border: InputBorder.none,
          counterText: '',
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.length == maxLength && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else if (value.length == maxLength && isLast) {
            FocusScope.of(context).unfocus();
          }
        },
        onTap: () => HapticFeedback.selectionClick(),
      ),
    )
        .animate()
        .fadeIn(
            delay: (hint == 'DD'
                    ? 0
                    : hint == 'MM'
                        ? 100
                        : 200)
                .ms,
            duration: 400.ms)
        .scale(
            begin: const Offset(0.8, 0.8),
            duration: 300.ms,
            curve: Curves.easeOut);
  }
}
