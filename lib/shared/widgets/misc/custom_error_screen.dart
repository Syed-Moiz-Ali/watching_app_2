import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/navigation/routes.dart';
import 'text_widget.dart';

enum ErrorSeverity { low, medium, high, critical }

class ErrorAnalyzer {
  static ErrorSeverity analyzeSeverity(FlutterErrorDetails details) {
    final exception = details.exception.toString().toLowerCase();
    final library = details.library?.toLowerCase() ?? '';

    // Critical errors that can crash the app
    if (exception.contains('outofmemory') ||
        exception.contains('stackoverflow') ||
        exception.contains('fatal') ||
        library.contains('engine')) {
      return ErrorSeverity.critical;
    }

    // High severity - UI breaking errors
    if (exception.contains('renderflex') ||
        exception.contains('renderbox') ||
        exception.contains('assertion') ||
        exception.contains('null check operator')) {
      return ErrorSeverity.high;
    }

    // Medium severity - functionality issues
    if (exception.contains('format') ||
        exception.contains('parse') ||
        exception.contains('network') ||
        exception.contains('socket')) {
      return ErrorSeverity.medium;
    }

    return ErrorSeverity.low;
  }

  static IconData getErrorIcon(FlutterErrorDetails details) {
    final exception = details.exception.toString().toLowerCase();

    if (exception.contains('network') || exception.contains('socket')) {
      return Icons.wifi_off_rounded;
    }
    if (exception.contains('permission') || exception.contains('access')) {
      return Icons.block_rounded;
    }
    if (exception.contains('format') || exception.contains('parse')) {
      return Icons.data_usage_rounded;
    }
    if (exception.contains('memory')) {
      return Icons.memory_rounded;
    }
    if (exception.contains('render') || exception.contains('layout')) {
      return Icons.broken_image_rounded;
    }
    if (exception.contains('null')) {
      return Icons.help_outline_rounded;
    }

    return Icons.error_outline_rounded;
  }

  static String getUserFriendlyMessage(FlutterErrorDetails details) {
    final exception = details.exception.toString().toLowerCase();

    if (exception.contains('network') || exception.contains('socket')) {
      return 'Connection issue detected';
    }
    if (exception.contains('permission')) {
      return 'Permission required';
    }
    if (exception.contains('format') || exception.contains('parse')) {
      return 'Data processing error';
    }
    if (exception.contains('memory')) {
      return 'Memory issue detected';
    }
    if (exception.contains('render') || exception.contains('overflow')) {
      return 'Display layout issue';
    }
    if (exception.contains('null')) {
      return 'Missing data detected';
    }

    return 'Technical issue encountered';
  }
}

class CustomErrorScreen extends StatefulWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorScreen({super.key, required this.errorDetails});

  @override
  State<CustomErrorScreen> createState() => _CustomErrorScreenState();
}

class _CustomErrorScreenState extends State<CustomErrorScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showTechnicalDetails = false;

  // Context detection
  bool _isDebugMode = false;
  Size? _screenSize;
  bool _isCompactScreen = false;

  @override
  void initState() {
    super.initState();
    _detectContext();
    _setupAnimations();
  }

  void _detectContext() {
    // Detect debug mode
    assert(() {
      _isDebugMode = true;
      return true;
    }());

    // Detect screen size after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final mediaQuery = MediaQuery.of(context);
        _screenSize = mediaQuery.size;
        _isCompactScreen =
            _screenSize!.width < 400 || _screenSize!.height < 600;
        if (mounted) setState(() {});
      }
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildErrorTheme(context),
      home: Scaffold(
        body: _buildErrorBody(),
      ),
    );
  }

  ThemeData _buildErrorTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }

  Widget _buildErrorBody() {
    final severity = ErrorAnalyzer.analyzeSeverity(widget.errorDetails);
    final icon = ErrorAnalyzer.getErrorIcon(widget.errorDetails);
    final message = ErrorAnalyzer.getUserFriendlyMessage(widget.errorDetails);

    return Container(
      decoration: _buildBackgroundDecoration(severity),
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: _isCompactScreen
              ? _buildCompactLayout(severity, icon, message)
              : _buildFullLayout(severity, icon, message),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(ErrorSeverity severity) {
    Color primaryColor;
    switch (severity) {
      case ErrorSeverity.critical:
        primaryColor = Colors.red;
        break;
      case ErrorSeverity.high:
        primaryColor = Colors.orange;
        break;
      case ErrorSeverity.medium:
        primaryColor = Colors.amber;
        break;
      case ErrorSeverity.low:
        primaryColor = Colors.blue;
        break;
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.1),
          Theme.of(context).colorScheme.background,
          Theme.of(context).colorScheme.background,
        ],
        stops: const [0.0, 0.3, 1.0],
      ),
    );
  }

  Widget _buildCompactLayout(
      ErrorSeverity severity, IconData icon, String message) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedIcon(icon, severity, compact: true),
          SizedBox(height: 12.sp),
          _buildErrorTitle(severity, compact: true),
          SizedBox(height: 8.sp),
          _buildErrorMessage(message, compact: true),
          SizedBox(height: 20.sp),
          _buildCompactActions(),
          if (_isDebugMode) ...[
            SizedBox(height: 16.sp),
            _buildQuickDebugInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildFullLayout(
      ErrorSeverity severity, IconData icon, String message) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.sp),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          _buildAnimatedIcon(icon, severity),
          SizedBox(height: 20.sp),
          _buildErrorTitle(severity),
          SizedBox(height: 12.sp),
          _buildErrorMessage(message),
          SizedBox(height: 8.sp),
          _buildErrorId(),
          SizedBox(height: 30.sp),
          _buildSuggestions(severity),
          SizedBox(height: 24.sp),
          _buildActionButtons(),
          if (_isDebugMode) ...[
            SizedBox(height: 20.sp),
            _buildTechnicalSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, ErrorSeverity severity,
      {bool compact = false}) {
    final color = _getSeverityColor(severity);
    final size = compact ? 20.sp : 30.sp;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(compact ? 12.sp : 20.sp),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Icon(
              icon,
              size: size,
              color: color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorTitle(ErrorSeverity severity, {bool compact = false}) {
    return TextWidget(
      text: 'Oops! Something went wrong',
      fontSize: compact ? 16.sp : 22.sp,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onBackground,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage(String message, {bool compact = false}) {
    return TextWidget(
      text: _isDebugMode
          ? message
          : 'We apologize for the inconvenience. The app encountered an unexpected issue.',
      fontSize: compact ? 12.sp : 14.sp,
      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final errorId = 'ERR-${timestamp.toString().substring(8)}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fingerprint,
            size: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4.sp),
          TextWidget(
            text: 'Error ID: $errorId',
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ErrorSeverity severity) {
    List<String> suggestions = [
      'Try refreshing or restarting the app',
      'Check your internet connection',
      'Close other apps to free up memory',
    ];

    if (severity == ErrorSeverity.critical) {
      suggestions = [
        'Restart the app immediately',
        'Restart your device if problem persists',
        'Contact support with the error ID above',
      ];
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.sp),
                TextWidget(
                  text: 'What you can try:',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            SizedBox(height: 12.sp),
            ...suggestions
                .map((suggestion) => Padding(
                      padding: EdgeInsets.only(bottom: 6.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4.sp,
                            height: 4.sp,
                            margin: EdgeInsets.only(top: 6.sp, right: 8.sp),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: TextWidget(
                              text: suggestion,
                              fontSize: 12.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _restartApp,
            icon: Icon(Icons.refresh_rounded, size: 16.sp),
            label: TextWidget(text: 'Restart App'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.sp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.sp),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.sp),
        TextButton(
          onPressed: _goToHome,
          child: TextWidget(text: 'Go to Home', fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _restartApp,
                icon: Icon(Icons.refresh_rounded, size: 18.sp),
                label: TextWidget(text: 'Restart App'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToHome,
                icon: Icon(Icons.home_rounded, size: 18.sp),
                label: TextWidget(text: 'Go Home'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        TextButton.icon(
          onPressed: _copyErrorInfo,
          icon: Icon(Icons.copy_rounded, size: 14.sp),
          label: TextWidget(text: 'Copy Error Info'),
          style: TextButton.styleFrom(
            foregroundColor:
                Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickDebugInfo() {
    return ExpansionTile(
      title: TextWidget(
        text: 'Debug Info',
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      leading: Icon(Icons.code, size: 16.sp),
      childrenPadding: EdgeInsets.all(12.sp),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: TextWidget(
            text: widget.errorDetails.exception.toString(),
            fontSize: 10.sp,
            maxLine: 100,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
        side: BorderSide(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: ExpansionTile(
        title: TextWidget(
          text: 'Technical Details',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.error,
        ),
        leading: Icon(
          Icons.bug_report_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTechnicalDetail(
                    'Exception', widget.errorDetails.exception.toString()),
                if (widget.errorDetails.library != null) ...[
                  SizedBox(height: 12.sp),
                  _buildTechnicalDetail(
                      'Library', widget.errorDetails.library!),
                ],
                if (widget.errorDetails.context != null) ...[
                  SizedBox(height: 12.sp),
                  _buildTechnicalDetail(
                      'Context', widget.errorDetails.context.toString()),
                ],
                if (widget.errorDetails.stack != null) ...[
                  SizedBox(height: 12.sp),
                  _buildTechnicalDetail(
                      'Stack Trace', widget.errorDetails.stack.toString()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetail(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: label,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
            IconButton(
              onPressed: () => _copyToClipboard(content, label),
              icon: Icon(Icons.copy, size: 14.sp),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        SizedBox(height: 4.sp),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: label == 'Stack Trace' ? 40.h : 20.h,
          ),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        return Colors.red;
      case ErrorSeverity.high:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.amber;
      case ErrorSeverity.low:
        return Colors.blue;
    }
  }

  void _restartApp() {
    // Navigate to splash/main route to restart app flow
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.splash,
      (route) => false,
    );
  }

  void _goToHome() {
    // Navigate to home route
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.splash,
      (route) => false,
    );
  }

  void _copyErrorInfo() {
    final errorInfo = '''
Error ID: ERR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}
Time: ${DateTime.now().toString()}
Exception: ${widget.errorDetails.exception}
Library: ${widget.errorDetails.library ?? 'Unknown'}
''';

    _copyToClipboard(errorInfo, 'Error Info');
  }

  void _copyToClipboard(String content, String type) {
    Clipboard.setData(ClipboardData(text: content));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(text: '$type copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
