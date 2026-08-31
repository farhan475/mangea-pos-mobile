class PopularDishModel {
  final String id;
  final String name;
  final int soldCount;
  final String? imageUrl;

  const PopularDishModel({
    required this.id,
    required this.name,
    required this.soldCount,
    this.imageUrl,
  });
}
