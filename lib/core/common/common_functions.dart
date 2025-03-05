import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/global/app_global.dart';

import '../constants/color_constants.dart';
import '../enums/app_enums.dart';
import '../../presentation/provider/theme_provider.dart';
import '../../presentation/widgets/buttons/primary_button.dart';
import '../../presentation/widgets/misc/text_widget.dart';

class CommonFunctions {
  static scrollToIndex({
    double? height,
    required ScrollController scrollController,
    required String type,
    required List data,
  }) {
    // Loop through the data to find the index of the first item of the selected type
    for (int i = 0; i < data.length; i++) {
      // log('i is $i and type is ${data[i]['type']} and provded type is $type');
      if (data[i]['type'] == type) {
        // Scroll to the index of the first matching type
        scrollController.animateTo(
          i *
              (height ??
                  18.h), // Adjust this multiplier for the height of your items
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }

  static logOutBottomSheet() {
    return customBottomSheet(
        icon: Icons.exit_to_app,
        title: 'Logout',
        description: 'Are you sure you want to logout?',
        btnText: 'Logout',
        onTap: () async {
          var pref = SMA.pref!;
          pref.clear();

          // await Turf.navigateTo(const SplashScreen());
        });
  }

  static customBottomSheet({
    IconData? icon,
    String? title,
    String? description,
    String? btnText,
    Function? onTap,
    Widget? child,
    Function? onCancel,
    bool addPadding = true,
    bool isScrollControlled = true,
  }) {
    if (child == null) {
      // Ensure the required parameters are provided if no child is given
      assert(icon != null, 'Icon is required when no child is provided.');
      assert(title != null, 'Title is required when no child is provided.');
      assert(description != null,
          'Description is required when no child is provided.');
      assert(btnText != null,
          'Button text is required when no child is provided.');
    }
    showModalBottomSheet(
      context: SMA.navigationKey.currentContext!,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedPadding(
          padding: addPadding
              ? EdgeInsets.only(
                  top: 20, left: 16, right: 16, bottom: SMA.size.height * .1)
              : EdgeInsets.zero,
          duration: const Duration(
              milliseconds: 300), // Adding smooth padding animation
          child: child ??
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with Icon
                  Icon(
                    icon,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  // Title with stronger font size and weight
                  TextWidget(
                    text: title!,
                    styleType: TextStyleType.heading,
                    fontSize: 28, // Increased font size
                    fontWeight:
                        FontWeight.bold, // Stronger emphasis on the title
                  ),
                  const SizedBox(height: 8),
                  // Subtitle with more line spacing for readability
                  TextWidget(
                    text: description!,
                    styleType: TextStyleType.subheading,
                    maxLine: 2,
                    textAlign: TextAlign.center,
                    fontSize: 16, // Slightly larger font for readability
                  ),
                  const SizedBox(height: 24), // Increased space below the text
                  // Action buttons in a row with balanced spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel button with new style and icon
                      PrimaryButton(
                        onTap: () {
                          onCancel!();
                          Navigator.of(context).pop(); // Cancel action
                        },
                        text: 'Cancel',
                        width: SMA.size.width * .35,
                        borderRadius: 12,

                        elevation:
                            3, // Adding subtle elevation for a modern button look
                      ),
                      const SizedBox(width: 16), // Add space between buttons
                      // Logout button with accent color and elevated design
                      PrimaryButton(
                        onTap: () => onTap!(),
                        text: btnText,
                        width: SMA.size.width * .35,
                        borderRadius: 12,

                        elevation: 5, // Slightly higher elevation to stand out
                      ),
                    ],
                  ),
                ],
              ),
        );
      },
    );
  }

  static BoxShadow getBoxShadow(BuildContext context) {
    bool isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: true).isDarkTheme;

    return BoxShadow(
      color: isDarkTheme
          ? AppColors.backgroundColorLight.withOpacity(0.2)
          : AppColors.backgroundColorDark.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    );
  }

  // Fetch Background Color based on the current theme
  static Color getBgColor(BuildContext context, {bool isEqual = true}) {
    // Access the current theme state
    bool isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: true).isDarkTheme;

    // If isEqual is true, apply the logic you want to adjust based on it
    if (!isEqual) {
      // You can adjust the logic here for when isEqual is false
      // For now, it directly flips the theme
      isDarkTheme = !isDarkTheme;
    }

    // Return the background color based on the theme condition
    return isDarkTheme
        ? AppColors.backgroundColorDark
        : AppColors.backgroundColorLight;
  }
}
