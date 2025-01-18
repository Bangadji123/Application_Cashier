import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditBarangAdminPage extends StatefulWidget {
  final Map<String, dynamic> product;

  EditBarangAdminPage({required this.product});

  @override
  _EditBarangAdminPageState createState() => _EditBarangAdminPageState();
}

class _EditBarangAdminPageState extends State<EditBarangAdminPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _stokController;
  late TextEditingController _hargaController;
  String _selectedSatuan = 'Pcs';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
        text: widget.product['Nama_Produk'] as String? ?? '');
    _stokController = TextEditingController(
        text: widget.product['Stok_Produk'] as String? ?? '');
    _hargaController = TextEditingController(
        text: _formatCurrency(widget.product['Harga_Produk'] as int? ?? 0));
    _selectedSatuan = widget.product['Satuan'] as String? ?? 'Pcs';
  }

  String _formatCurrency(int value) {
    final format = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.toString().replaceAllMapped(format, (Match m) => '${m[1]},');
  }

  String _unformatCurrency(String value) {
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response =
            await Supabase.instance.client.from('tbl_produk').update({
          'Nama_Produk': _namaController.text,
          'Stok_Produk': _stokController.text,
          'Harga_Produk': int.parse(_unformatCurrency(_hargaController.text)),
          'Satuan': _selectedSatuan,
        }).match({'id': widget.product['id']}).execute();

        if (mounted) {
          _showAlert('Sukses', 'Barang berhasil diupdate', false);
        }
      } catch (e) {
        if (mounted) {
          _showAlert('Error', 'Terjadi kesalahan: ${e.toString()}', true);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Supabase.instance.client
          .from('tbl_produk')
          .delete()
          .eq('id', widget.product['id'])
          .execute();

      if (response.status != 200) {
        _showAlert('Error', 'Terjadi kesalahan saat menghapus data', true);
      } else {
        _showAlert('Sukses', 'Barang berhasil dihapus', false);
      }
    } catch (e) {
      _showAlert('Error', 'Terjadi kesalahan: ${e.toString()}', true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAlert(String title, String message, bool isError) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: isError ? Colors.red[100] : Colors.green[100],
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (!isError) {
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Barang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 70,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Nama Barang', _namaController),
                      _buildTextField('Stok Barang', _stokController),
                      _buildTextField('Harga Barang', _hargaController,
                          isNumeric: true, prefix: 'Rp. '),
                      _buildDropdown(),
                      SizedBox(height: 25),
                      _buildDeleteButton(),
                      SizedBox(height: 50),
                      _buildConfirmButton(screenWidth, screenHeight),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: TextStyle(fontWeight: FontWeight.bold),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          onChanged: isNumeric
              ? (value) {
                  if (value.isNotEmpty) {
                    final unformattedValue = _unformatCurrency(value);
                    final formattedValue =
                        _formatCurrency(int.parse(unformattedValue));
                    controller.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                          offset: formattedValue.length),
                    );
                  }
                }
              : null,
          decoration: InputDecoration(
            prefixText: isNumeric ? null : prefix,
            prefixStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black.withOpacity(0.8),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field ini tidak boleh kosong';
            }
            if (isNumeric) {
              final unformattedValue = _unformatCurrency(value);
              if (int.tryParse(unformattedValue) == null) {
                return 'Field ini hanya boleh berisi angka';
              }
            }
            return null;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Harga Per Satuan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedSatuan,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          items: <String>[
            'Kg',
            'Liter',
            'Pcs',
            'Box',
            'Botol',
            'Rim',
            'Kantong'
          ].map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSatuan = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Konfirmasi'),
              content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
              actions: [
                TextButton(
                  child: Text('Batal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Hapus'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteProduct();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.delete, color: Colors.red, size: 18),
          SizedBox(width: 10),
          Text(
            'Hapus Barang',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _updateProduct,
          child: Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.08,
            decoration: ShapeDecoration(
              color: Color(0xFF3FA2F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Konfirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
