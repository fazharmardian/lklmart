import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/cart.dart';
import '../../data/models/item.dart';
import '../../data/services/api_service.dart';
import 'invoice.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool isLoading = false;
  List<Item> items = [];
  List<Item> filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  // Cart state
  List<CartItem> cartItems = [];
  Map<int, int> itemQuantities = {}; // Tracks quantities for each item
  Map<int, bool> itemInCart = {}; // Tracks if item is in cart

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getItems() async {
    setState(() => isLoading = true);
    try {
      final apiService = ApiService();
      final response = await apiService.getItems();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          items = (responseData['items'] as List)
              .map((item) => Item.fromJson(item))
              .toList();
          filteredItems = List.from(items); // Initialize filtered list

          // Initialize quantities and cart status
          for (var item in items) {
            itemQuantities[item.id] = 0;
            itemInCart[item.id] = false;
          }
        });
      } else {
        if (mounted) {
          AnimatedSnackBar.material(
            'Failed to load items',
            type: AnimatedSnackBarType.error,
          ).show(context);
        }
      }
    } catch (e) {
      if (mounted) {
        AnimatedSnackBar.material(
          e.toString(),
          type: AnimatedSnackBarType.error,
        ).show(context);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(items);
      } else {
        filteredItems = items
            .where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addToCart(Item item) {
    final quantity = itemQuantities[item.id] ?? 0;
    if (quantity <= 0) return;

    setState(() {
      cartItems.add(CartItem(item: item, quantity: quantity));
      itemInCart[item.id] = true;
      itemQuantities[item.id] = 0; // Reset quantity after adding to cart
    });
  }

  void _removeFromCart(int itemId) {
    setState(() {
      cartItems.removeWhere((cartItem) => cartItem.item.id == itemId);
      itemInCart[itemId] = false;
    });
  }

  double get _totalCartPrice {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildProductList()),
                ],
              ),
            ),
          ),
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "LKS MART",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF315472),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Produk',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF315472),
            ),
          ),
          SizedBox(
            width: 150,
            height: 30,
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Cari produk...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? const Icon(Icons.search, size: 16)
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _searchItems('');
                        },
                      ),
              ),
              onSubmitted: _searchItems,
              onChanged: (value) {
                // Optional: search as you type
                // _searchItems(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          'No products available',
          style: GoogleFonts.inter(fontSize: 16),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return _buildProductItem(item);
        },
      ),
    );
  }

  Widget _buildProductItem(Item item) {
    final quantity = itemQuantities[item.id] ?? 0;
    final isInCart = itemInCart[item.id] ?? false;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                // 'http://lks-2025.test/storage/${item.image}',
                'http://192.168.137.1/lks-2025/public/storage/${item.image}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amberAccent,
                          ),
                          Text(
                            '4.6',
                            style: const TextStyle(fontSize: 11),
                          )
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'Rp.${item.price}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (quantity > 0) {
                                setState(() {
                                  itemQuantities[item.id] = quantity - 1;
                                });
                              }
                            },
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                              color: quantity > 0 ? null : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$quantity',
                            style: GoogleFonts.poppins(),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: isInCart
                                ? null
                                : () {
                                    setState(() {
                                      itemQuantities[item.id] = quantity + 1;
                                    });
                                  },
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 20,
                              color: isInCart ? Colors.grey : null,
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isInCart) {
                            _removeFromCart(item.id);
                          } else if (quantity > 0) {
                            _addToCart(item);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isInCart
                                ? Colors.red
                                : (quantity > 0
                                    ? Colors.lightBlue
                                    : Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            isInCart
                                ? Icons.close
                                : Icons.shopping_cart_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: 'Total Belanja  ',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF315472),
              ),
              children: [
                TextSpan(
                  text: ':Rp.${_totalCartPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: cartItems.isEmpty
                ? null
                : () {
                    navigateToInvoice(cartItems);
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 40),
              backgroundColor:
                  cartItems.isEmpty ? Colors.grey : Colors.greenAccent[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Bayar Sekarang',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void navigateToInvoice(List<CartItem> cartItems) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(
          cartItems: cartItems,
          purchaseDate: DateTime.now(),
        ),
      ),
    );
  }
}
