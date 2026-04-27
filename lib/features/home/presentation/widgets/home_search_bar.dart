import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class HomeSearchBar extends StatefulWidget {
  final double sw;
  const HomeSearchBar({super.key, required this.sw});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(
        horizontal: widget.sw * 0.05,
        vertical: widget.sw * 0.02,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _searchController,
              hinttext: 'Search collections, styles...',
              fillColor: AppColors.offWhite,
              borderRadius: widget.sw * 0.04,
              margin: .zero,
              contentPadding: .symmetric(
                vertical: widget.sw * 0.03,
                horizontal: widget.sw * 0.04,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.charcoal.withValues(alpha: 0.4),
                size: widget.sw * 0.055,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, size: widget.sw * 0.04),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (val) => setState(() {}),
              textInputAction: .search,
            ),
          ),
          SizedBox(width: widget.sw * 0.01),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: widget.sw * 0.09,
      width: widget.sw * 0.09,
      decoration: BoxDecoration(
        color: AppColors.camel,
        borderRadius: .circular(widget.sw * 0.03),
        boxShadow: [
          BoxShadow(
            color: AppColors.camel.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: .circular(widget.sw * 0.02),
          onTap: () {},
          child: Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: widget.sw * 0.05,
          ),
        ),
      ),
    );
  }
}
