import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailPesananPage extends StatefulWidget {
  final Map<int, int> selectedProducts;
  final List<Map<String, dynamic>> products;
  final double totalAmount;
  final VoidCallback onTransactionSuccess;

  const DetailPesananPage({
    Key? key,
    required this.selectedProducts,
    required this.products,
    required this.totalAmount,
    required this.onTransactionSuccess,
  }) : super(key: key);

  @override
  _DetailPesananPageState createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  String selectedPetugas = '';
  String selectedPayment = 'Cash';
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  List<String> petugasList = [];
  final List<String> paymentMethods = ['Cash', 'QRIS', 'Transfer Bank'];

  @override
  void initState() {
    super.initState();
    _loadPetugasList();
  }

  Future<void> _loadPetugasList() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_adminpetugas')
          .select('Nama_Username')
          .eq('Role', 'Petugas')
          .execute();

      if (response.data != null) {
        setState(() {
          petugasList = (response.data as List)
              .map((item) => item['Nama_Username'].toString())
              .toList();
          // Set nilai default untuk selectedPetugas jika list tidak kosong
          if (petugasList.isNotEmpty) {
            selectedPetugas = petugasList[0];
          }
        });
      }
    } catch (e) {
      print('Error loading petugas list: $e');
    }
  }

  Widget _buildOrderItems() {
    return Column(
      children: widget.selectedProducts.entries.map((entry) {
        final product = widget.products.firstWhere((p) => p['id'] == entry.key);
        final total = (product['Harga_Produk'] ?? 0) * entry.value;

        return _buildOrderItemRow({
          'name': product['Nama_Produk'],
          'quantity': '${entry.value} x',
          'price': 'Rp. $total',
        });
      }).toList(),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      children: [
        Divider(color: Colors.grey),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Rp. ${NumberFormat('#,###').format(widget.totalAmount)}',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tambahkan method untuk menyimpan pesanan
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Berhasil'),
          content: Text('Transaksi telah berhasil'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                widget.onTransactionSuccess();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gagal'),
          content: Text('Terjadi kesalahan saat transaksi: $error'),
          actions: [
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

  void _savePesanan() async {
    try {
      String productDetails = widget.selectedProducts.entries.map((entry) {
        final product = widget.products.firstWhere((p) => p['id'] == entry.key);
        return "${product['Nama_Produk']}:${entry.value}";
      }).join(',');

      String shortId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13);

      // Validasi stok dengan pengecekan null safety yang lebih baik
      for (var entry in widget.selectedProducts.entries) {
        final product = widget.products.firstWhere((p) => p['id'] == entry.key);
        final currentStock =
            int.tryParse(product['Stok_Produk']?.toString() ?? '0') ?? 0;
        if (currentStock < entry.value) {
          throw 'Stok tidak mencukupi untuk ${product['Nama_Produk']}';
        }
      }

      final pesanan = {
        'Id_Pesanan': shortId,
        'Produk': productDetails,
        'Total': widget.totalAmount.toInt(),
        'Nama': selectedPetugas,
        'Pembayaran': selectedPayment,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Simpan ke tbl_history
      await Supabase.instance.client.from('tbl_history').insert(pesanan);

      // Update stok produk dengan pengecekan null safety yang lebih baik
      for (var entry in widget.selectedProducts.entries) {
        final product = widget.products.firstWhere((p) => p['id'] == entry.key);
        final currentStock =
            int.tryParse(product['Stok_Produk']?.toString() ?? '0') ?? 0;
        final newStock = currentStock - entry.value;

        await Supabase.instance.client
            .from('tbl_produk')
            .update({'Stok_Produk': newStock}).eq('id', entry.key);
      }

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(e.toString());
      print('Error saving order: $e');
    }
  }

  Widget _buildOrderItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            item['quantity'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Rp. ${NumberFormat('#,###').format(int.parse(item['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')))}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID Pesanan
          Text(
            'Id Pesanan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            orderId,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),

          // Dropdown Nama Petugas
          Text(
            'Nama Petugas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedPetugas,
            isExpanded: true,
            underline: Container(),
            items: petugasList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedPetugas = newValue!;
              });
            },
          ),
          SizedBox(height: 16),

          // Dropdown Metode Pembayaran
          Text(
            'Pembayaran',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedPayment,
            isExpanded: true,
            underline: Container(),
            items: paymentMethods.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedPayment = newValue!;
              });
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFormSection(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildOrderItems(),
                  _buildTotalSection(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePesanan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 25),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(
                      'Konfirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
