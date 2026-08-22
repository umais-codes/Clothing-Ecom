import 'package:flutter/material.dart';

/// Professional, luxury & high-conversion e-commerce color design system.
///
/// Features:
/// - WCAG 2.1 AA compliant contrast ratios for optimal accessibility.
/// - Calibrated neutral surfaces to reduce eye fatigue during extended shopping.
/// - Clear commercial intent tokens (promotions, stock urgency, trust signals).
/// - 100% backward-compatible with all existing app views and components.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // 1. BRAND & LUXURY ACCENTS
  // ---------------------------------------------------------------------------

  /// Soft Gold / Camel - Primary luxury hero accent for buttons, active tabs & badges.
  static const Color camel = Color(0xFFC19A6B);

  /// Pale Camel Tint - Soft background for active filter pills & selection chips.
  static const Color camelLight = Color(0xFFF7EFE4);

  /// Deep Camel - Pressed/hover state for primary camel elements.
  static const Color camelDark = Color(0xFFA67C4E);

  /// Muted Terracotta Rose - Accent for curated fashion & seasonal lookbooks.
  static const Color rose = Color(0xFFD4856A);

  /// Soft Rose Tint - Background tint for lifestyle & collection chips.
  static const Color roseLight = Color(0xFFFBECE7);

  /// Muted Sage - Sustainable, organic & wellness collection accent.
  static const Color sage = Color(0xFF7A9E87);

  /// Soft Sage Tint - Background tint for sustainable tags.
  static const Color sageLight = Color(0xFFEBF3EE);

  /// Corporate Navy - Formal B2B procurement and enterprise accent.
  static const Color navy = Color(0xFF1E293B);

  /// Soft Navy Tint - Background tint for corporate invoices & cards.
  static const Color navyLight = Color(0xFFF1F5F9);

  // ---------------------------------------------------------------------------
  // 2. BACKGROUNDS & NEUTRAL SURFACES
  // ---------------------------------------------------------------------------

  /// Pure Canvas White - Cards, dialogs, bottom sheets & elevated surfaces.
  static const Color white = Color(0xFFFFFFFF);

  /// Gallery Ivory - Base scaffold background (eliminates harsh glare on OLED/LCD).
  static const Color offWhite = Color(0xFFFAF9F6);

  /// Soft Alabaster - Unselected segmented controls, secondary card surfaces.
  static const Color cream = Color(0xFFF3EFEA);

  /// Subtle Neutral Surface - Search input fields and empty state containers.
  static const Color surfaceSubtle = Color(0xFFF8F8F9);

  /// Elevated Card Surface - Highlighted card background.
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // 3. TYPOGRAPHY & NEUTRALS
  // ---------------------------------------------------------------------------

  /// Dark Ink - Primary titles, product names & high-contrast body text (WCAG AAA).
  static const Color charcoal = Color(0xFF18181B);

  /// Medium Ink - Secondary descriptions, spec sheets & subtitle text.
  static const Color ink = Color(0xFF3F3F46);

  /// Muted Grey - Timestamps, SKU codes, breadcrumbs & form helper labels.
  static const Color grey = Color(0xFF71717A);

  /// Hairline Border Grey - Card outlines, table dividers & input borders.
  static const Color greyLight = Color(0xFFE4E4E7);

  /// Subtle Divider Grey - Inactive divider tracks and subtle separators.
  static const Color greySubtle = Color(0xFFEFECE8);

  /// Disabled Grey - Inactive button labels and disabled icons.
  static const Color greyDisabled = Color(0xFFA1A1AA);

  // ---------------------------------------------------------------------------
  // 4. E-COMMERCE CONVERSION & COMMERCIAL SIGNALS
  // ---------------------------------------------------------------------------

  /// Sale / Discount Price - High-urgency red to draw direct attention to savings.
  static const Color sale = Color(0xFFE53935);

  /// Soft Sale Background - Pill background for discount tags (e.g. "-30%").
  static const Color saleLight = Color(0xFFFDECEC);

  /// Discount Accent - Slash-through price accents and promo banners.
  static const Color discount = Color(0xFFD32F2F);

  /// Discount Background Tint.
  static const Color discountLight = Color(0xFFFEECEB);

  /// 5-Star Rating Amber - Reviews, verified customer ratings & reward stars.
  static const Color starRating = Color(0xFFF59E0B);

  /// Star Rating Chip Background.
  static const Color starRatingBg = Color(0xFFFEF3C7);

  /// Trust & Security Blue - SSL checkout, verified brand guarantee & warranty.
  static const Color trustBadge = Color(0xFF2563EB);

  /// Trust Badge Background.
  static const Color trustBadgeLight = Color(0xFFEFF6FF);

  /// Express Delivery / Free Shipping Green.
  static const Color freeShipping = Color(0xFF059669);

  /// Free Shipping Pill Background.
  static const Color freeShippingLight = Color(0xFFECFDF5);

  /// Low Stock Alert - Subtle urgency cue ("Only 2 left in stock").
  static const Color lowStock = Color(0xFFD97706);

  /// Low Stock Alert Background.
  static const Color lowStockLight = Color(0xFFFFFBEB);

  // ---------------------------------------------------------------------------
  // 5. MERCHANDISING BADGES
  // ---------------------------------------------------------------------------

  /// "NEW IN" Badge - Fresh teal accent.
  static const Color badgeNew = Color(0xFF0D9488);
  static const Color badgeNewLight = Color(0xFFCCFBF1);

  /// "BEST SELLER" Badge - Deep indigo accent.
  static const Color badgeBestSeller = Color(0xFF4F46E5);
  static const Color badgeBestSellerLight = Color(0xFFEEF2FF);

  /// "TRENDING" Badge - Vibrant coral accent.
  static const Color badgeTrending = Color(0xFFEA580C);
  static const Color badgeTrendingLight = Color(0xFFFFEDD5);

  /// "VIP / EXCLUSIVE" Badge - Royal purple accent.
  static const Color badgeExclusive = Color(0xFF7C3AED);
  static const Color badgeExclusiveLight = Color(0xFFF5F3FF);

  // ---------------------------------------------------------------------------
  // 6. SYSTEM STATUS & HUMAN UX FEEDBACK
  // ---------------------------------------------------------------------------

  /// Success - Order confirmed, profile saved, KYC verified.
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFEDF7ED);
  static const Color successBorder = Color(0xFFC8E6C9);

  /// Warning - Low inventory warning, pending approvals.
  static const Color warning = Color(0xFFD48B38);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color warningBorder = Color(0xFFFFE082);

  /// Error - Form errors, payment declined, application rejected.
  static const Color error = Color(0xFFC0392B);
  static const Color errorBg = Color(0xFFFDEDED);
  static const Color errorBorder = Color(0xFFFFCDD2);

  /// Info - Logistics tracking notes, system announcements.
  static const Color info = Color(0xFF0284C7);
  static const Color infoBg = Color(0xFFF0F9FF);
  static const Color infoBorder = Color(0xFFBAE6FD);

  // ---------------------------------------------------------------------------
  // 7. SKELETON SHIMMER & INTERACTION OVERLAYS
  // ---------------------------------------------------------------------------

  /// Shimmer placeholder base color.
  static const Color shimmerBase = Color(0xFFE8E5E0);

  /// Shimmer placeholder moving highlight.
  static const Color shimmerHighlight = Color(0xFFF9F7F5);

  /// Dark backdrop scrim for modals & dialogs.
  static const Color scrimDark = Color(0x99000000);

  /// Light touch ripple overlay.
  static const Color overlayLight = Color(0x0D000000);

  // ---------------------------------------------------------------------------
  // 8. GRADIENT TOKENS
  // ---------------------------------------------------------------------------

  /// Premium gold gradient for promotional banners & VIP membership cards.
  static const LinearGradient luxuryGoldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFC19A6B), Color(0xFFA67C4E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark navy gradient for corporate headers & high-contrast widgets.
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// High-urgency promotional sale gradient.
  static const LinearGradient saleGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Skeleton loader shimmer gradient.
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [shimmerBase, shimmerHighlight, shimmerBase],
    stops: [0.1, 0.5, 0.9],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // ---------------------------------------------------------------------------
  // 9. ELEVATION SHADOW TOKENS
  // ---------------------------------------------------------------------------

  /// Soft, modern card shadow for product tiles and surface elevation.
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: charcoal.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Elevated shadow for floating action bars and sticky bottom checkout bars.
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: charcoal.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
