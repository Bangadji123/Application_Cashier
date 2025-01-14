// class Product {
//   final int id;
//   final String name;
//   final int stock;
//   final int price;
//   final String unit;

//   Product({
//     required this.id,
//     required this.name,
//     required this.stock,
//     required this.price,
//     required this.unit,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       name: json['Nama_Produk'],
//       stock: int.parse(json['Stok_Produk'].toString()),
//       price: json['Harga_Produk'],
//       unit: json['Satuan'],
//     );
//   }
// }

// // cart_item.dart
// class CartItem {
//   final Product product;
//   final int quantity;

//   CartItem({required this.product, required this.quantity});

//   int get totalPrice => product.price * quantity;
// }

// // order.dart
// class Order {
//   final String id;
//   final List<CartItem> items;
//   final double total;
//   final DateTime date;
//   final String petugasName;
//   final String paymentMethod;

//   Order({
//     required this.id,
//     required this.items,
//     required this.total,
//     required this.date,
//     required this.petugasName,
//     required this.paymentMethod,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'Id_Pesanan': id,
//       'Produk': items.map((item) => '${item.product.name} (${item.quantity}x)').join(', '),
//       'Total': total,
//       'Nama': petugasName,
//       'Pembayaran': paymentMethod,
//       'created_at': date.toIso8601String(),
//     };
//   }

//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       id: json['Id_Pesanan'],
//       items: [], // You may need to fetch product details separately
//       total: json['Total'].toDouble(),
//       date: DateTime.parse(json['created_at']),
//       petugasName: json['Nama'],
//       paymentMethod: json['Pembayaran'],
//     );
//   }
// }