import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor = AppColors.white,
    this.elevation = 0.5,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final double actionIconSize = context.sp(sw * 0.06);

    // Professionally style and override action icon sizes if they are IconButtons
    final List<Widget>? processedActions = actions?.map((action) {
      if (action is IconButton) {
        return IconButton(
          key: action.key,
          icon: action.icon,
          onPressed: action.onPressed,
          iconSize: actionIconSize,
          color: action.color ?? AppColors.charcoal,
          tooltip: action.tooltip,
          padding: action.padding,
          alignment: action.alignment,
          splashRadius: action.splashRadius,
          focusNode: action.focusNode,
          autofocus: action.autofocus,
          enableFeedback: action.enableFeedback,
          constraints: action.constraints,
        );
      }
      return action;
    }).toList();

    final bool canPop = Navigator.canPop(context);

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: AppColors.greyLight.withValues(alpha: 0.4),
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: leading ??
          ((showBackButton && canPop)
               ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.charcoal,
                    size: context.sp(sw * 0.06),
                  ),
                  onPressed: onBackPressed ?? () => Get.back(),
                )
              : null),
      title: titleWidget ??
          Text(
            title ?? '',
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.055),
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
      centerTitle: true,
      actions: (processedActions != null && processedActions.isNotEmpty)
          ? processedActions
          : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
