import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final double elevation;
  final bool centerTitle;
  final bool showBottomBorder;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor = AppColors.offWhite,
    this.elevation = 0.0,
    this.centerTitle = true,
    this.showBottomBorder = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final bool canPop = Navigator.canPop(context);

    // Adaptive luminance-based contrast coloring according to AppTheme
    final bool isDarkBg = backgroundColor.computeLuminance() < 0.5;
    final Color foregroundColor = isDarkBg
        ? AppColors.white
        : AppColors.charcoal;
    final Color subtitleColor = isDarkBg
        ? AppColors.camelLight
        : AppColors.camel;

    // Process action items with responsive sizing and adaptive theme coloring
    final List<Widget>? processedActions = actions?.map((action) {
      if (action is IconButton) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: IconButton(
            key: action.key,
            icon: action.icon,
            onPressed: action.onPressed,
            iconSize: action.iconSize ?? context.sp(sw * 0.055),
            color: action.color ?? foregroundColor,
            tooltip: action.tooltip,
            padding: action.padding ?? const EdgeInsets.all(8),
            alignment: action.alignment ?? Alignment.center,
            splashRadius: action.splashRadius ?? 22,
            constraints: action.constraints,
          ),
        );
      }
      return action;
    }).toList();

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && canPop) {
      leadingWidget = Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: foregroundColor,
                size: context.sp(sw * 0.048),
              ),
              onPressed: onBackPressed ?? () => Get.back(),
              tooltip: 'Back',
              splashRadius: 20,
            ),
          ),
        ),
      );
    }

    Widget? finalTitleWidget = titleWidget;
    if (finalTitleWidget == null && title != null && title!.isNotEmpty) {
      finalTitleWidget = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.05),
              fontWeight: FontWeight.w700,
              color: foregroundColor,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: context.sp(sw * 0.024),
                fontWeight: FontWeight.w600,
                color: subtitleColor,
                letterSpacing: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: showBottomBorder
                ? AppColors.greyLight
                : AppColors.greyLight.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: leadingWidget,
        title: finalTitleWidget,
        centerTitle: centerTitle,
        actions: (processedActions != null && processedActions.isNotEmpty)
            ? processedActions
            : null,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
