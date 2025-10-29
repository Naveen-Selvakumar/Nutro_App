class ProductModel {
  final String id;
  final String name;
  final Map<String, dynamic>? nutrition;

  ProductModel({required this.id, required this.name, this.nutrition});
}
