import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all products from the database
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _supabase.from('tbl_produk').select();
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // Add a new product to the database
  Future<void> addProduct(String nama, int stok, int harga, String satuan) async {
    await _supabase.from('tbl_produk').insert({
      'Nama_Produk': nama,
      'Stok_Produk': stok,
      'Harga_Produk': harga,
      'Satuan': satuan,
    });
  }

  // Update an existing product in the database
  Future<void> updateProduct(
      int id, String nama, int stok, int harga, String satuan) async {
    await _supabase.from('tbl_produk').update({
      'Nama_Produk': nama,
      'Stok_Produk': stok,
      'Harga_Produk': harga,
      'Satuan': satuan,
    }).eq('id', id);
  }

  // Delete a product from the database
  Future<void> deleteProduct(int id) async {
    await _supabase.from('tbl_produk').delete().eq('id', id);
  }

  // Search for products by a query string
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final response = await _supabase
        .from('tbl_produk')
        .select()
        .ilike('Nama_Produk', '%$query%');
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }
}