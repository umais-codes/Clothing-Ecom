---
name: flutter-design
description: >
  Flutter UI/UX design best practices for the ecom_app project (Valvet Maison).
  Use this skill when building any screen, widget, or UI component. Covers the project
  design system (AppColors, AppTheme, typography, responsive sizing), shared widget
  catalogue, animation patterns, shimmer loading, glassmorphism, and luxury e-commerce
  UI conventions. Always read this skill before creating or significantly editing any
  presentation layer file.
---

# Flutter Design Best Practices — ecom_app (Valvet Maison)

## 1. Design Identity

Valvet Maison is a **luxury fashion e-commerce app**. Every screen must feel:
- **Premium** — tasteful white space, refined typography, muted colour palette
- **Trustworthy** — consistent spacing, legible text, clear CTAs
- **Responsive** — looks great on any phone width, scales to tablet

Never use raw colours like `Colors.red`, `Colors.blue`, `Color(0xFF...)` inline.
Always use a token from `AppColors`.

---

## 2. AppColors — Design Token System

Import path: `package:ecom_app/app/theme/app_colors.dart`

### Brand & Luxury Accents

| Token | Hex | Use |
|---|---|---|
| `AppColors.camel` | `#C19A6B` | Primary CTA accent, active tab, badge |
| `AppColors.camelLight` | `#F7EFE4` | Active filter pill background |
| `AppColors.camelDark` | `#A67C4E` | Pressed/hover camel |
| `AppColors.rose` | `#D4856A` | Fashion & seasonal accent |
| `AppColors.sage` | `#7A9E87` | Sustainable / wellness accent |
| `AppColors.navy` | `#1E293B` | Corporate B2B accent |

### Backgrounds & Surfaces

| Token | Use |
|---|---|
| `AppColors.white` | Cards, dialogs, elevated surfaces |
| `AppColors.offWhite` | Scaffold background |
| `AppColors.cream` | Unselected chips, secondary card surfaces |
| `AppColors.surfaceSubtle` | Search input background |

### Typography Neutrals

| Token | Use |
|---|---|
| `AppColors.charcoal` | Primary text (titles, product names) |
| `AppColors.ink` | Secondary text (descriptions) |
| `AppColors.grey` | Muted text (timestamps, helper labels) |
| `AppColors.greyLight` | Borders, dividers |
| `AppColors.greySubtle` | Subtle separators |
| `AppColors.greyDisabled` | Disabled states |

### E-Commerce Signal Tokens

| Token | Use |
|---|---|
| `AppColors.sale` / `saleLight` | Discount price / pill |
| `AppColors.starRating` / `starRatingBg` | Star rating chip |
| `AppColors.freeShipping` / `freeShippingLight` | Free shipping badge |
| `AppColors.lowStock` / `lowStockLight` | Low stock urgency cue |
| `AppColors.trustBadge` / `trustBadgeLight` | Secure checkout badge |

### Merchandising Badges

| Token | Use |
|---|---|
| `AppColors.badgeNew` / `badgeNewLight` | "NEW IN" |
| `AppColors.badgeBestSeller` / `badgeBestSellerLight` | "BEST SELLER" |
| `AppColors.badgeTrending` / `badgeTrendingLight` | "TRENDING" |
| `AppColors.badgeExclusive` / `badgeExclusiveLight` | "VIP / EXCLUSIVE" |

### Status Colours

| Token | Use |
|---|---|
| `AppColors.success` / `successBg` | Order confirmed, KYC verified |
| `AppColors.warning` / `warningBg` | Pending approval, low inventory |
| `AppColors.error` / `errorBg` | Form errors, payment declined |
| `AppColors.info` / `infoBg` | Logistics notes |

### Gradients (Ready to Use)

```dart
// Primary CTA gradient (camel → rose) — used in CustomButton.primary
const LinearGradient(
  colors: [AppColors.camel, AppColors.rose],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Luxury gold — promo banners, VIP cards
AppColors.luxuryGoldGradient

// Dark navy — corporate headers
AppColors.darkCardGradient

// Sale urgency
AppColors.saleGradient

// Shimmer animation
AppColors.shimmerGradient
```

### Shadows (Ready to Use)

```dart
// Standard card shadow
boxShadow: AppColors.cardShadow,

// Floating bar shadow (nav bar, checkout sticky footer)
boxShadow: AppColors.floatingShadow,
```

---

## 3. Typography — AppTheme Text Styles

Import: `package:ecom_app/app/theme/app_theme.dart`

**Fonts used:**
- `Playfair Display` — editorial headings (`displayLarge`, `displayMedium`, `displaySmall`, `headlineMedium`)
- `Outfit` — UI body copy, labels, buttons, subtitles

### Use via Theme

```dart
// Editorial headline (Playfair)
Text('New Collection', style: Theme.of(context).textTheme.displaySmall)

// Section title (Outfit bold)
Text('Featured Products', style: Theme.of(context).textTheme.titleLarge)

// Body copy
Text(description, style: Theme.of(context).textTheme.bodyMedium)

// Small muted label
Text(sku, style: Theme.of(context).textTheme.bodySmall)

// Tracking/badge label (uppercase)
Text('NEW IN', style: Theme.of(context).textTheme.labelLarge)
```

### Direct GoogleFonts (for inline custom sizes)

```dart
import 'package:google_fonts/google_fonts.dart';

// Product card price
Text(
  'PKR 4,500',
  style: GoogleFonts.outfit(
    fontSize: sw * 0.038,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
  ),
)

// Sale price with strikethrough
Text(
  'PKR 6,000',
  style: GoogleFonts.outfit(
    fontSize: sw * 0.032,
    color: AppColors.grey,
    decoration: TextDecoration.lineThrough,
  ),
)
```

---

## 4. Responsive Sizing — context.screenWidth Pattern

Import: `package:ecom_app/app/utils/responsive.dart`

**The project uses proportional sizing exclusively.** Never use raw pixel values for layout dimensions.

```dart
final double sw = context.screenWidth;
final double sh = context.screenHeight;

// Spacing
SizedBox(height: sw * 0.04)   // ~15px on 375px screen
SizedBox(width: sw * 0.03)

// Padding
padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04)

// Font size
fontSize: sw * 0.035   // ~13px
fontSize: sw * 0.04    // ~15px
fontSize: sw * 0.045   // ~17px

// Border radius
borderRadius: BorderRadius.circular(sw * 0.03)   // ~11px
borderRadius: BorderRadius.circular(sw * 0.04)   // ~15px

// Icon size
size: sw * 0.05   // ~19px
size: sw * 0.06   // ~22px

// Card height
height: sw * 0.5   // square-ish card
height: sw * 0.6   // taller product card
```

### Responsive Utilities Available

```dart
// Check device type
context.isMobileView   // < 700px
context.isTabletView   // 700–1100px
context.isDesktopView  // > 1100px

// Percentage helpers
context.wp(50)   // 50% of screen width
context.hp(20)   // 20% of screen height

// Scaled font size (auto-scales for tablet/desktop)
context.sp(14)

// Responsive widget switch
context.responsive<Widget>(
  mobile: SmallLayout(),
  tablet: MediumLayout(),
  desktop: WideLayout(),
)

// ResponsiveLayout widget
ResponsiveLayout(
  mobile: PhoneWidget(),
  tablet: TabletWidget(),
)
```

---

## 5. Shared Widget Catalogue

These widgets already exist — use them instead of building from scratch.

### CustomButton

```dart
import 'package:ecom_app/app/widgets/custom_button.dart';

// Primary (camel→rose gradient, white text)
CustomButton(
  text: 'Add to Cart',
  onPressed: () {},
  variant: ButtonVariant.primary,
)

// Secondary (ghost surface)
CustomButton(
  text: 'View Details',
  onPressed: () {},
  variant: ButtonVariant.secondary,
)

// Outlined (border only)
CustomButton(
  text: 'Cancel',
  onPressed: () {},
  variant: ButtonVariant.outlined,
)

// Ghost (no background or border)
CustomButton(
  text: 'Skip',
  onPressed: () {},
  variant: ButtonVariant.ghost,
)

// With loading state
CustomButton(
  text: 'Processing...',
  isLoading: controller.isLoading.value,
  onPressed: controller.submit,
)

// With icon
CustomButton(
  text: 'Checkout',
  icon: Icons.shopping_bag_outlined,
  onPressed: () {},
)
```

### CustomTextField

```dart
import 'package:ecom_app/app/widgets/custom_text_field.dart';

CustomTextField(
  label: 'Email Address',
  controller: emailController,
  icon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  isRequired: true,
  hinttext: 'you@example.com',
  validator: (v) => v!.isEmpty ? 'Required' : null,
)

// Multiline
CustomTextField(
  label: 'Product Description',
  controller: descController,
  maxLines: 4,
  hinttext: 'Describe the product...',
)

// Password field
CustomTextField(
  label: 'Password',
  controller: passController,
  obscureText: true,
  suffixIcon: IconButton(
    icon: const Icon(Icons.visibility_outlined),
    onPressed: () {},
  ),
)
```

### CustomNetworkImage

```dart
import 'package:ecom_app/app/widgets/custom_network_image.dart';

// Auto shimmer placeholder + error state
CustomNetworkImage(
  imageUrl: product.imageUrl,
  width: sw * 0.4,
  height: sw * 0.5,
  borderRadius: sw * 0.03,
  fit: BoxFit.cover,
)

// As ImageProvider (for decorations)
DecorationImage(
  image: CustomNetworkImage.provider(url),
  fit: BoxFit.cover,
)
```

### CustomAppBar

```dart
import 'package:ecom_app/app/widgets/custom_app_bar.dart';

// Use for all screens (keeps visual consistency)
appBar: CustomAppBar(title: 'My Orders')
```

---

## 6. Card Design Convention

Product cards and content tiles follow this pattern:

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(sw * 0.04),
    border: Border.all(
      color: AppColors.greyLight.withValues(alpha: 0.4),
    ),
    boxShadow: AppColors.cardShadow,
  ),
  child: ...,
)
```

For elevated / featured cards:
```dart
BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(sw * 0.04),
  boxShadow: AppColors.floatingShadow,
)
```

---

## 7. Shimmer Loading Pattern

Use `Shimmer` + `AppColors.shimmerBase` / `shimmerHighlight` for all loading states.

```dart
import 'package:shimmer/shimmer.dart';

Widget _buildProductShimmer(double sw) {
  return Shimmer.fromColors(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    child: Column(
      children: List.generate(4, (_) => Container(
        margin: EdgeInsets.symmetric(vertical: sw * 0.02),
        height: sw * 0.25,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(sw * 0.03),
        ),
      )),
    ),
  );
}
```

Show shimmer when `isLoading.value == true`, swap to real content on completion.

---

## 8. Glassmorphism Pattern (Nav Bar Style)

As used in `CustomFloatingNavBar`:

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.white.withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(sw * 0.09),
    border: Border.all(
      color: AppColors.camel.withValues(alpha: 0.15),
      width: 0.5,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.charcoal.withValues(alpha: 0.12),
        blurRadius: 20,
        spreadRadius: -8,
        offset: const Offset(0, 12),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(sw * 0.09),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: child,
    ),
  ),
)
```

Apply to: modals, bottom sheets, floating action bars.

---

## 9. Animation Patterns

### Nav Item Selection (Elastic)

```dart
AnimatedPositioned(
  duration: const Duration(milliseconds: 350),
  curve: Curves.elasticOut,
  left: selectedIndex * itemWidth,
  child: activeIndicator,
)
```

### Button Disable Fade

```dart
AnimatedOpacity(
  duration: const Duration(milliseconds: 100),
  opacity: isDisabled ? 0.6 : 1.0,
  child: button,
)
```

### Page / List Item Entrance

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeOut,
  height: isExpanded ? expandedHeight : collapsedHeight,
  child: content,
)
```

### Splash Ripple on Taps

```dart
InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(sw * 0.03),
  splashColor: AppColors.camel.withValues(alpha: 0.1),
  highlightColor: AppColors.camel.withValues(alpha: 0.05),
  child: content,
)
```

---

## 10. Badge / Tag Widgets

Standard badge pill pattern:

```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: sw * 0.02,
    vertical: sw * 0.008,
  ),
  decoration: BoxDecoration(
    color: AppColors.badgeNewLight,
    borderRadius: BorderRadius.circular(sw * 0.02),
  ),
  child: Text(
    'NEW IN',
    style: GoogleFonts.outfit(
      fontSize: sw * 0.025,
      fontWeight: FontWeight.w800,
      color: AppColors.badgeNew,
      letterSpacing: 0.8,
    ),
  ),
)
```

Apply same pattern with appropriate `badgeXxx` / `badgeXxxLight` colour pair for:
`BEST SELLER`, `TRENDING`, `EXCLUSIVE`, `SALE`, `FREE SHIPPING`, `LOW STOCK`.

---

## 11. Status Banner / Alert Pattern

```dart
Container(
  padding: EdgeInsets.all(sw * 0.04),
  decoration: BoxDecoration(
    color: AppColors.successBg,
    borderRadius: BorderRadius.circular(sw * 0.03),
    border: Border.all(color: AppColors.successBorder),
  ),
  child: Row(
    children: [
      Icon(Icons.check_circle_outline, color: AppColors.success, size: sw * 0.05),
      SizedBox(width: sw * 0.03),
      Expanded(
        child: Text(
          'Order placed successfully!',
          style: GoogleFonts.outfit(color: AppColors.success, fontSize: sw * 0.034),
        ),
      ),
    ],
  ),
)
```

Replace `success*` with `warning*`, `error*`, or `info*` tokens for other states.

---

## 12. Empty State Pattern

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.shopping_bag_outlined,
        size: sw * 0.18,
        color: AppColors.greyDisabled,
      ),
      SizedBox(height: sw * 0.04),
      Text(
        'Your cart is empty',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      SizedBox(height: sw * 0.02),
      Text(
        'Start exploring our collections',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: sw * 0.06),
      CustomButton(
        text: 'Shop Now',
        onPressed: () => Get.toNamed(AppRoutes.discovery),
      ),
    ],
  ),
)
```

---

## 13. Screen Scaffold Template

```dart
class MyFeatureScreen extends StatelessWidget {
  const MyFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final ctrl = Get.find<MyController>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CustomAppBar(title: 'Screen Title'),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return _buildShimmer(sw);
        }
        if (ctrl.errorMessage.value.isNotEmpty) {
          return _buildError(sw, ctrl.errorMessage.value);
        }
        if (ctrl.items.isEmpty) {
          return _buildEmpty(sw);
        }
        return _buildContent(sw, ctrl);
      }),
    );
  }
}
```

---

## 14. Navigation (GetX Routing)

Always use named routes from `AppRoutes`:

```dart
import 'package:ecom_app/app/routes/app_routes.dart';

// Navigate to
Get.toNamed(AppRoutes.productDetails, arguments: productMap)

// Replace current
Get.offNamed(AppRoutes.mainNavigation)

// Clear stack and go
Get.offAllNamed(AppRoutes.splash)

// Go back
Get.back()
```

Pass data via `arguments` (Map or model), read with `Get.arguments` on destination screen.

---

## 15. Common Anti-Patterns to Avoid

| Wrong | Correct |
|---|---|
| `Color(0xFFC19A6B)` inline | `AppColors.camel` |
| `Colors.red` | `AppColors.error` |
| Fixed `height: 48` | `height: sw * 0.13` |
| `fontSize: 14` | `fontSize: sw * 0.037` |
| `Text('...', style: TextStyle(...))` without Outfit/Playfair | Use `GoogleFonts.outfit(...)` |
| `Image.network(url)` | `CustomNetworkImage(imageUrl: url, ...)` |
| Building buttons from scratch | `CustomButton(...)` |
| `Column` overflow without `Expanded`/`Flexible` | Wrap children properly |
| Hardcoded strings in UI | Use constants or l10n (future) |
| `print()` | `debugPrint()` |
