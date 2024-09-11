import 'package:application_cashier/Page/Petugas/SidebarPetugas.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPetugasPage extends StatefulWidget {
  const DashboardPetugasPage({super.key});

  @override
  State<DashboardPetugasPage> createState() => _DashboardPetugasPageState();
}

class _DashboardPetugasPageState extends State<DashboardPetugasPage> {
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
      setState(() {
        _isLoading = false;
      });

      // Show a more user-friendly error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Failed to load products. Please check your internet connection and try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Log the error for debugging purposes
      print('Error loading products: $e');
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
      drawer: SidebarPetugas(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dashboard Petugas',
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
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text(
                  'Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                value: false, // You'll need to manage this state
                onChanged: (bool? value) {
                  // Handle checkbox state change
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Rp.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                child: Text(
                  'Konfirm',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  // Handle confirm button press
                },
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, double screenWidth) {
    return Card(
      color: Colors.white,
      elevation: 4, // Increased elevation for more pronounced shadow
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.grey.withOpacity(0.5), // Added shadow color
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product['Nama_Produk'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Stok: ${product['Stok_Produk'] ?? '0'} ${product['Satuan'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Rp. ${product['Harga_Produk'] ?? 0}/${product['Satuan'] ?? 'pcs'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildCircularButton(Icons.remove, () {
                  // Implement decrease quantity logic
                }),
                SizedBox(width: 16),
                Text(
                  '1', // This should be a variable to track quantity
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 16),
                _buildCircularButton(Icons.add, () {
                  // Implement increase quantity logic
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.6)),
      ),
      child: Icon(icon, size: 15, color: Colors.black.withOpacity(0.8)),
    ),
  );
}
