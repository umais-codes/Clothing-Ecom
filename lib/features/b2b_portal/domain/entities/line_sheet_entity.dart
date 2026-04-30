class LineSheetEntity {
  final String id;
  final String name;
  final double price;
  final int minQty;
  final String composition;
  final String imageUrl;

  const LineSheetEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.minQty,
    required this.composition,
    required this.imageUrl,
  });
}
