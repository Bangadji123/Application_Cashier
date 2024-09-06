import 'package:application_cashier/Admin/Page/EditBarangAdminPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_cashier/Admin/Widget/Sidebar.dart';

class DashboardAdminPage extends StatefulWidget {
  @override
  _DashboardAdminPageState createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase
          .from('tbl_produk')
          .select()
          .order('id', ascending: true)
          .execute();

      if (response.data != null) {
        setState(() {
          _products =
              (response.data as List<dynamic>).cast<Map<String, dynamic>>();
          _filteredProducts = _products;
          _isLoading = false;
        });
      } else {
        throw Exception('No data received');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        final nameLower = product['Nama_Produk'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: Sidebar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Masukan Nama',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: _filterProducts,
            ),
          ),
          SizedBox(height: 16), // Add space between search bar and content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _filteredProducts.isEmpty
                        ? Center(child: Text('No products found'))
                        : ListView.builder(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _buildProductCard(product, screenWidth),
                              );
                            },
                          ),
                  ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, double screenWidth) {
    SizedBox(height: 20);
    return Container(
      width: screenWidth * 0.9,
      height: 100,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.1),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 10,
            child: Text(
              product['Nama_Produk'] ?? '',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 42,
            child: Text(
              'Stok: ${product['Stok_Produk'] ?? '0'}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontSize: 15,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 70,
            child: Text(
              'Rp. ${product['Harga_Produk'] ?? 0}/${product['Satuan'] ?? 'pcs'}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontSize: 15,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 40,
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBarangAdminPage(product: product),
                  ),
                );
                if (result == true) {
                  _loadProducts();
                }
              },
              child: Icon(
                Icons.edit,
                size: 25,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
