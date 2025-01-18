import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  Map<String, int> _productPrices = {};
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<int> _selectedItems = {};
  bool _selectAll = false;
  final screenshotController = ScreenshotController();
  String _selectedStaff = 'Semua Petugas';
  String _selectedDateRange = 'Semua';
  List<String> _staffList = ['Semua Petugas'];
  DateTime? _startDate;
  DateTime? _endDate;

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

  String formatRupiah(dynamic number) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(number);
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

        Set<String> staffSet = {'Semua Petugas'};
        for (var item in _history) {
          staffSet.add(item['Nama'].toString());
        }
        _staffList = staffSet.toList();
      });
    } catch (e) {
      print('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredHistory() {
    return _history.where((item) {
      bool staffMatch = _selectedStaff == 'Semua Petugas' ||
          item['Nama'].toString() == _selectedStaff;

      if (!staffMatch) return false;

      if (_startDate != null && _endDate != null) {
        DateTime itemDate = DateTime.parse(item['created_at']);
        return itemDate.isAfter(_startDate!) &&
            itemDate.isBefore(_endDate!.add(Duration(days: 1)));
      }

      switch (_selectedDateRange) {
        case 'Hari Ini':
          DateTime itemDate = DateTime.parse(item['created_at']);
          DateTime today = DateTime.now();
          return itemDate.year == today.year &&
              itemDate.month == today.month &&
              itemDate.day == today.day;
        case '7 Hari Terakhir':
          DateTime itemDate = DateTime.parse(item['created_at']);
          DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
          return itemDate.isAfter(sevenDaysAgo);
        case '30 Hari Terakhir':
          DateTime itemDate = DateTime.parse(item['created_at']);
          DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
          return itemDate.isAfter(thirtyDaysAgo);
        default:
          return true;
      }
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter History'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Petugas:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedStaff,
                    isExpanded: true,
                    items: _staffList.map((String staff) {
                      return DropdownMenuItem<String>(
                        value: staff,
                        child: Text(staff),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStaff = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Rentang Waktu:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedDateRange,
                    isExpanded: true,
                    items: [
                      'Semua',
                      'Hari Ini',
                      '7 Hari Terakhir',
                      '30 Hari Terakhir',
                      'Kustom'
                    ].map((String range) {
                      return DropdownMenuItem<String>(
                        value: range,
                        child: Text(range),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue == 'Kustom') {
                        DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked.start;
                            _endDate = picked.end;
                            _selectedDateRange = 'Kustom';
                          });
                        }
                      } else {
                        setState(() {
                          _selectedDateRange = newValue!;
                          _startDate = null;
                          _endDate = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Reset'),
                  onPressed: () {
                    setState(() {
                      _selectedStaff = 'Semua Petugas';
                      _selectedDateRange = 'Semua';
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                ),
                TextButton(
                  child: Text('Terapkan'),
                  onPressed: () {
                    this.setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    bool isSelected = _selectedItems.contains(index);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _selectedItems.add(index);
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedItems.remove(index);
              if (_selectedItems.isEmpty) {
                _isSelectionMode = false;
              }
            } else {
              _selectedItems.add(index);
            }
          });
        }
      },
      child: Container(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        child: Padding(
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
                  ..._history[index]['Produk']
                      .toString()
                      .split(',')
                      .map((prod) {
                    final parts = prod.split(':');
                    final name = parts[0];
                    final quantity = parts[1];
                    final price = _productPrices[name] ?? 0;
                    return _buildHistoryItem(
                      name,
                      quantity,
                      'Rp ${price.toString()}',
                    );
                  }).toList(),
                  const Divider(),
                  _buildTotalSection(
                      _history[index]['Total']?.toString() ?? '0'),
                  const SizedBox(height: 16),
                  _buildOrderDetails(
                    _history[index]['Id_Pesanan']?.toString() ?? '',
                    _history[index]['Nama']?.toString() ?? '',
                    _history[index]['Pembayaran']?.toString() ?? '',
                    _history[index]['created_at'] != null
                        ? DateTime.parse(_history[index]['created_at'])
                        : DateTime.now(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String name, String quantity, String price) {
    final priceValue = int.parse(price.replaceAll('Rp ', ''));
    final quantityValue = int.parse(quantity);
    final totalPrice = priceValue * quantityValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: _textStyle()),
          Text('$quantity x', style: _textStyle()),
          Text(formatRupiah(totalPrice), style: _textStyle()),
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
          Text(formatRupiah(int.parse(total)),
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

  void _showNotificationDialog(String title, String message, bool isError) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isError ? Icons.error : Icons.check_circle,
                color: isError ? Colors.red : Colors.green,
              ),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message),
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

  void _deleteSelectedItems() async {
    try {
      for (int index in _selectedItems) {
        final item = _history[index];
        await Supabase.instance.client
            .from('tbl_history')
            .delete()
            .eq('Id_Pesanan', item['Id_Pesanan'])
            .execute();
      }

      setState(() {
        _history = _history
            .where((item) => !_selectedItems.contains(_history.indexOf(item)))
            .toList();
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      _showNotificationDialog(
        'Sukses',
        'Item berhasil dihapus',
        false,
      );
    } catch (e) {
      _showNotificationDialog(
        'Error',
        'Gagal menghapus item: $e',
        true,
      );
    }
  }

  void _printSelectedItems() {
    // Implementasi print PDF/PNG akan ditambahkan di sini
    print('Printing selected items: ${_selectedItems.length} items');
  }

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Format Export'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Export sebagai PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportToPdf();
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Export sebagai PNG'),
              onTap: () {
                Navigator.pop(context);
                _exportToPng();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: _selectedItems.map((index) {
              final item = _history[index];
              final products = item['Produk'].toString().split(',');

              return pw.Container(
                margin: pw.EdgeInsets.all(10),
                padding: pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    ...products.map((prod) {
                      final parts = prod.split(':');
                      final name = parts[0];
                      final quantity = parts[1];
                      final price = _productPrices[name] ?? 0;
                      return pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(name),
                          pw.Text('$quantity x'),
                          pw.Text(formatRupiah(price * int.parse(quantity))),
                        ],
                      );
                    }).toList(),

                    pw.Divider(thickness: 1),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total'),
                        pw.Text(
                            formatRupiah(int.parse(item['Total'].toString())),
                            style: pw.TextStyle(color: PdfColors.red)),
                      ],
                    ),

                    pw.SizedBox(height: 10),

                    // Detail pesanan
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Id Pesanan'),
                        pw.Text('${item['Id_Pesanan']}'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Nama Petugas'),
                        pw.Text('${item['Nama']}'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Pembayaran'),
                        pw.Text('${item['Pembayaran']}'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tanggal Pesanan'),
                        pw.Text(DateTime.parse(item['created_at'])
                            .toString()
                            .split('.')[0]),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: 'history.pdf');

      _showNotificationDialog(
        'Sukses',
        'PDF berhasil dibuat',
        false,
      );
    } catch (e) {
      _showNotificationDialog(
        'Error',
        'Gagal membuat PDF: $e',
        true,
      );
    }
  }

  Future<void> _exportToPng() async {
    try {
      final imageFile = await screenshotController.captureFromWidget(
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _selectedItems.map((index) {
              final item = _history[index];
              final products = item['Produk'].toString().split(',');

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...products.map((prod) {
                      final parts = prod.split(':');
                      final name = parts[0];
                      final quantity = parts[1];
                      final price = _productPrices[name] ?? 0;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name),
                            Text('$quantity x'),
                            Text(formatRupiah(price * int.parse(quantity))),
                          ],
                        ),
                      );
                    }).toList(),

                    Divider(thickness: 1),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total'),
                        Text(
                          formatRupiah(int.parse(item['Total'].toString())),
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Detail pesanan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Id Pesanan'),
                        Text('${item['Id_Pesanan']}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nama Petugas'),
                        Text('${item['Nama']}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pembayaran'),
                        Text('${item['Pembayaran']}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tanggal Pesanan'),
                        Text(DateTime.parse(item['created_at'])
                            .toString()
                            .split('.')[0]),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: imageFile,
        filename: 'history_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      _showNotificationDialog(
        'Sukses',
        'PNG berhasil dibuat',
        false,
      );
    } catch (e) {
      _showNotificationDialog(
        'Error',
        'Gagal membuat PNG: $e',
        true,
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text(
              'Apakah Anda yakin ingin menghapus ${_selectedItems.length} item yang dipilih?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSelectedItems();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _isSelectionMode
              ? "${_selectedItems.length} item dipilih"
              : "History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedItems.clear();
                    _selectAll = false;
                  });
                },
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: Icon(
                _selectAll ? Icons.select_all : Icons.deselect,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (_selectAll) {
                    _selectedItems.clear();
                  } else {
                    _selectedItems =
                        Set.from(List.generate(_history.length, (i) => i));
                  }
                  _selectAll = !_selectAll;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed:
                  _selectedItems.isNotEmpty ? _showDeleteConfirmation : null,
            ),
            IconButton(
              icon: Icon(Icons.file_download_outlined),
              onPressed: _selectedItems.isNotEmpty ? _showExportOptions : null,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(Icons.filter_alt, size: 25),
                onPressed: _showFilterDialog,
              ),
            ),
          ],
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        elevation: 4,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _getFilteredHistory().length,
              itemBuilder: (context, index) {
                final item = _getFilteredHistory()[index];
                return _buildHistoryCard(item, index);
              },
            ),
    );
  }
}
