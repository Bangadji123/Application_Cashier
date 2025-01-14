import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  Map<String, int> _productPrices = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadProductPrices();
    await _loadHistory();
  }

  Future<void> _loadProductPrices() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_produk')
          .select('Nama_Produk, Harga_Produk')
          .execute();

      final data = response.data as List<dynamic>;
      final prices = {
        for (var d in data)
          d['Nama_Produk'].toString(): int.parse(d['Harga_Produk'].toString())
      };
      setState(() => _productPrices = prices);
    } catch (e) {
      print('Error loading product prices: $e');
    }
  }

  Future<void> _loadHistory() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_history')
          .select()
          .order('created_at', ascending: false)
          .execute();

      setState(() {
        _history =
            (response.data as List<dynamic>).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    List<Map<String, String>> products = [];
    if (item['Produk'] != null) {
      products =
          item['Produk'].toString().split(',').map<Map<String, String>>((prod) {
        final parts = prod.split(':');
        final name = parts[0];
        final quantity = parts[1];
        final price = _productPrices[name] ?? 0;
        return {
          'name': name,
          'quantity': quantity,
          'price': price.toString(),
        };
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...products.map((prod) => _buildHistoryItem(
                    prod['name'] ?? '',
                    '${prod['quantity']}',
                    'Rp ${prod['price']}',
                  )),
              const Divider(),
              _buildTotalSection(item['Total']?.toString() ?? '0'),
              const SizedBox(height: 16),
              _buildOrderDetails(
                item['Id_Pesanan']?.toString() ?? '',
                item['Nama']?.toString() ?? '',
                item['Pembayaran']?.toString() ?? '',
                item['created_at'] != null
                    ? DateTime.parse(item['created_at'])
                    : DateTime.now(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String name, String quantity, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: _textStyle()),
          Text(quantity, style: _textStyle()),
          Text(price, style: _textStyle()),
        ],
      ),
    );
  }

  Widget _buildTotalSection(String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: _textStyle(weight: FontWeight.bold)),
          Text('Rp. $total',
              style: _textStyle(weight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(
      String orderId, String nama, String pembayaran, DateTime createdAt) {
    return Column(
      children: [
        _buildDetailRow('Id Pesanan', orderId),
        _buildDetailRow('Nama Petugas', nama),
        _buildDetailRow('Pembayaran', pembayaran),
        _buildDetailRow(
          'Tanggal Pesanan',
          '${createdAt.day}/${createdAt.month}/${createdAt.year}\n${createdAt.hour}:${createdAt.minute}',
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _textStyle()),
          Text(value, style: _textStyle()),
        ],
      ),
    );
  }

  TextStyle _textStyle(
      {FontWeight weight = FontWeight.normal, Color color = Colors.black}) {
    return TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.file_download_outlined, size: 25),
              onPressed: () {
                print('Download button pressed');
              },
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        elevation: 4,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return _buildHistoryCard(item);
              },
            ),
    );
  }
}
