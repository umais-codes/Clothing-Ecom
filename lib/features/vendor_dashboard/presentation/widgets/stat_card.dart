import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final Map<String, String> stat;
  final double sw;

  const StatCard({super.key, required this.stat, required this.sw});

  @override
  Widget build(BuildContext context) {
    final bool isCamel = stat['color'] == 'camel';

    final Color accentColor = isCamel ? AppColors.camel : AppColors.charcoal;
    final Color bgColor = isCamel ? AppColors.camelLight : AppColors.white;
    final Color borderColor = isCamel
        ? AppColors.camel.withValues(alpha: 0.2)
        : AppColors.greyLight;
    final IconData icon = _resolveIcon();

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: .circular(sw * 0.04),
        border: Border(left: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isCamel ? 0.08 : 0.04),
            blurRadius: sw * 0.035,
            offset: Offset(0, sw * 0.012),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(
              width: sw * 0.008,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCamel
                      ? [AppColors.camel, AppColors.rose]
                      : [AppColors.charcoal, AppColors.ink],
                  begin: .topCenter,
                  end: .bottomCenter,
                ),
                borderRadius: .circular(sw * 0.02),
              ),
            ),
          ),

          // content
          Padding(
            padding: .fromLTRB(sw * 0.04, sw * 0.01, sw * 0.03, sw * 0.01),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .center,
              children: [
                // icon badge
                Container(
                  width: sw * 0.08,
                  height: sw * 0.08,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: .circular(sw * 0.025),
                  ),
                  child: Icon(icon, size: sw * 0.038, color: accentColor),
                ),
                SizedBox(height: sw * 0.018),

                // label
                Text(
                  stat['title']!.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.024,
                    color: AppColors.grey,
                    letterSpacing: 0.9,
                    fontWeight: .w500,
                  ),
                ),
                SizedBox(height: sw * 0.006),

                // value
                FittedBox(
                  fit: .scaleDown,
                  alignment: .centerLeft,
                  child: Text(
                    stat['value']!,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.04,
                      fontWeight: .w700,
                      color: accentColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon() {
    final title = stat['title']!.toLowerCase();
    if (title.contains('sales')) return Icons.bar_chart_rounded;
    if (title.contains('order')) return Icons.receipt_long_rounded;
    if (title.contains('payout') || title.contains('revenue')) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.insights_rounded;
  }
}
