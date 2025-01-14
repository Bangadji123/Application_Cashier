// import 'package:application_cashier/Product.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseManager {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   Future<List<Product>> getProducts() async {
//     try {
//       final response = await _supabase
//           .from('tbl_produk')
//           .select()
//           .order('id', ascending: true);

//       // The response is already a List<dynamic>, no need to check for errors
//       return (response as List<dynamic>)
//           .map((json) => Product.fromJson(json))
//           .toList();
//     } catch (e) {
//       print('Error fetching products: $e');
//       rethrow;
//     }
//   }

//   Future<void> saveOrder(Order order) async {
//     final response =
//         await _supabase.from('tbl_history').insert(order.toJson()).execute();

//     if (response.data != null) {
//       throw response.data!;
//     }

//     // Update product stock
//     for (var item in order.items) {
//       await _updateProductStock(item.product.id, item.quantity);
//     }
//   }

//   Future<void> _updateProductStock(int productId, int soldQuantity) async {
//     final response = await _supabase
//         .from('tbl_produk')
//         .update({'Stok_Produk': 'Stok_Produk - $soldQuantity'})
//         .eq('id', productId)
//         .execute();

//     if (response.data != null) {
//       throw response.data!;
//     }
//   }

//   Future<List<Order>> getOrderHistory() async {
//     final response = await _supabase
//         .from('tbl_history')
//         .select()
//         .order('created_at', ascending: false)
//         .execute();

//     if (response.data != null) {
//       throw response.data!;
//     }

//     return (response.data as List<dynamic>)
//         .map((json) => Order.fromJson(json))
//         .toList();
//   }
// }
