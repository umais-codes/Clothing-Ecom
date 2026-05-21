import '../../../wishlist/domain/models/product_model.dart';

abstract class DiscoveryRepository {
  Future<List<Product>> getProducts({required bool isB2B});
}
