import 'package:application_cashier/Page/Petugas/SidebarPetugas.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'DetailPesananPetugasPage.dart';

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
  Map<int, int> _selectedProducts = {};
  double _totalAmount = 0.0;

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
                'Gagal memuat produk. Silakan periksa koneksi internet Anda dan coba lagi.'),
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

  void _updateTotal() {
    double total = 0.0;
    _selectedProducts.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p['id'] == productId);
      total += (product['Harga_Produk'] ?? 0) * quantity;
    });
    setState(() {
      _totalAmount = total;
    });
  }

  void _showStockErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Stok tidak mencukupi!'),
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
  }

  void _resetSelectedProducts() {
    setState(() {
      _selectedProducts.clear();
      _totalAmount = 0.0;
      _loadProducts(); // Memuat ulang data produk
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
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Total: Rp. ${NumberFormat('#,###').format(_totalAmount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  'Konfirm',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _selectedProducts.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPesananPage(
                              selectedProducts: _selectedProducts,
                              products: _products,
                              totalAmount: _totalAmount,
                              onTransactionSuccess: _resetSelectedProducts,
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, double screenWidth) {
    final productId = product['id'];
    final quantity = _selectedProducts[productId] ?? 0;
    final hargaSatuan = num.tryParse(product['Harga_Produk'].toString()) ?? 0;
    final stok = num.tryParse(product['Stok_Produk'].toString()) ?? 0;
    final totalHarga = hargaSatuan * quantity;

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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['Nama_Produk']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Stok: ${product['Stok_Produk']?.toString() ?? '0'} ${product['Satuan']?.toString() ?? ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Rp. ${NumberFormat('#,###').format(hargaSatuan)}/${product['Satuan']?.toString() ?? 'pcs'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Total: Rp. ${NumberFormat('#,###').format(totalHarga)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  color: quantity > 0 ? Colors.blue : Colors.grey,
                  onPressed: quantity > 0
                      ? () {
                          setState(() {
                            if (_selectedProducts[productId] != null &&
                                _selectedProducts[productId]! > 0) {
                              _selectedProducts[productId] =
                                  _selectedProducts[productId]! - 1;
                              if (_selectedProducts[productId] == 0) {
                                _selectedProducts.remove(productId);
                              }
                              _updateTotal();
                            }
                          });
                        }
                      : null,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String inputValue = quantity.toString();
                        TextEditingController inputController =
                            TextEditingController(text: inputValue);
                        return AlertDialog(
                          title: Text('Masukkan Jumlah'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            controller: inputController,
                            onChanged: (value) {
                              inputValue = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Jumlah produk',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                final newQuantity =
                                    int.tryParse(inputValue) ?? 0;
                                if (newQuantity >= 0) {
                                  if (newQuantity <= stok) {
                                    setState(() {
                                      if (newQuantity == 0) {
                                        _selectedProducts.remove(productId);
                                      } else {
                                        _selectedProducts[productId] =
                                            newQuantity;
                                      }
                                      _updateTotal();
                                    });
                                    Navigator.pop(context);
                                  } else {
                                    _showStockErrorDialog();
                                  }
                                }
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      quantity.toString(),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  color: stok > quantity ? Colors.blue : Colors.grey,
                  onPressed: stok > quantity
                      ? () {
                          if (quantity < stok) {
                            setState(() {
                              _selectedProducts[productId] = (quantity) + 1;
                              _updateTotal();
                            });
                          } else {
                            _showStockErrorDialog();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
