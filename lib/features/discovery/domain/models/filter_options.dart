import 'package:flutter/material.dart';

class FilterOptions {
  final String searchQuery;
  final String category;
  final RangeValues priceRange;
  final List<String> selectedSizes;
  final List<String> selectedColors;
  final int? maxMoq;
  final List<String> sourcingTypes;
  final List<String> locations;
  final String sortBy;

  const FilterOptions({
    this.searchQuery = '',
    this.category = '',
    this.priceRange = const RangeValues(0.0, 1000.0),
    this.selectedSizes = const [],
    this.selectedColors = const [],
    this.maxMoq,
    this.sourcingTypes = const [],
    this.locations = const [],
    this.sortBy = 'Popularity',
  });

  FilterOptions copyWith({
    String? searchQuery,
    String? category,
    RangeValues? priceRange,
    List<String>? selectedSizes,
    List<String>? selectedColors,
    int? maxMoq,
    bool clearMoq = false,
    List<String>? sourcingTypes,
    List<String>? locations,
    String? sortBy,
  }) {
    return FilterOptions(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      selectedColors: selectedColors ?? this.selectedColors,
      maxMoq: clearMoq ? null : (maxMoq ?? this.maxMoq),
      sourcingTypes: sourcingTypes ?? this.sourcingTypes,
      locations: locations ?? this.locations,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
