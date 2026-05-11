import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

class AdminDataTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<int>? columnFlex;
  final List<T> items;
  final Widget Function(T item) rowBuilder;
  final VoidCallback? onAddPressed;
  final String title;

  const AdminDataTable({
    super.key,
    required this.columns,
    this.columnFlex,
    required this.items,
    required this.rowBuilder,
    this.onAddPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .circular(12),
        border: .all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(2).clamp(12.0, 16.0),
              vertical: context.wp(1).clamp(8.0, 10.0),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(16).clamp(16.0, 28.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const Spacer(),
                if (onAddPressed != null)
                  CustomButton(
                    text: 'Add New',
                    icon: Icons.add,
                    onPressed: onAddPressed,
                    variant: ButtonVariant.primary,
                    height: context.wp(10).clamp(10.0, 40.0),
                    fontSize: context.sp(10).clamp(12.0, 28.0),
                    textColor: AppColors.white,
                    buttonColor: AppColors.camel,
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.greyLight),

          // ── Scrollable Data Area ────────────────────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double minTableWidth = 800.0;
                final double tableWidth = constraints.maxWidth < minTableWidth
                    ? minTableWidth
                    : constraints.maxWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // ── Column Headers ────────────────────────────────────
                        Container(
                          color: AppColors.offWhite,
                          padding: .symmetric(horizontal: 8, vertical: 2),
                          child: Row(
                            children: List.generate(columns.length, (index) {
                              return Expanded(
                                flex: columnFlex?[index] ?? 1,
                                child: Text(
                                  columns[index].toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.grey,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        const Divider(height: 1, color: AppColors.greyLight),

                        // ── Data Rows ─────────────────────────────────────────
                        Expanded(
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              color: AppColors.greyLight,
                            ),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: .symmetric(horizontal: 8, vertical: 6),
                                child: rowBuilder(items[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
