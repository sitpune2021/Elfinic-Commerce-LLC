import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ------------------- ORDERS SCREEN -------------------

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'ProductDetailPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<List<OrderItem>>? _ordersFuture;
  List<OrderItem> _allOrders = [];
  List<OrderItem> _filteredOrders = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = int.parse(prefs.getString("user_id") ?? "0");

    if (userId == 0) {
      debugPrint("User not logged in");
      return;
    }

    setState(() {
      _ordersFuture = ApiService.fetchOrders(userId);
    });
  }

  void _filterOrders(String status) {
    setState(() {
      _selectedFilter = status;
      if (status == 'All') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders
            .where((order) => order.status.toLowerCase() == status.toLowerCase())
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Orders",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _ordersFuture == null
          ? _buildShimmerLoading()
          : FutureBuilder<List<OrderItem>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _emptyOrders();
          }

          _allOrders = snapshot.data!;
          if (_filteredOrders.isEmpty) {
            _filteredOrders = _allOrders;
          }

          return Column(
            children: [
              // Filter Chips
              // _buildFilterChips(),

              // Orders Count
              _buildOrdersCount(),

              // Orders List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredOrders.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _filteredOrders[index];
                      return _orderCard(item);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(filter),
                selected: _selectedFilter == filter,
                onSelected: (selected) => _filterOrders(filter),
                backgroundColor: Colors.white,
                selectedColor: Colors.blue[50],
                labelStyle: TextStyle(
                  color: _selectedFilter == filter ? Colors.blue : Colors.grey[700],
                  fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: _selectedFilter == filter ? Colors.blue : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrdersCount() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '${_filteredOrders.length} ${_filteredOrders.length == 1 ? 'Order' : 'Orders'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Text(
            'Last 30 days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(OrderItem item) {
    final statusColor = _getStatusColor(item.status);
    final statusIcon = _getStatusIcon(item.status);
    final formattedDate = _formatDate(item.paidAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderHistoryScreen(
              orderId: item.orderId,
              productId: item.productId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Order Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${item.orderId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Placed on $formattedDate',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          item.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: "${ApiService.productImagePath}${item.productThumb}",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.shopping_bag,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Qty: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${item.finalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderHistoryScreen(
                              orderId: item.orderId,
                              productId: item.productId,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),


                  if (item.status.toLowerCase() == 'delivered')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Rate',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyOrders() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/empty_orders.png',
          height: 200,
          width: 200,
        ),
        const SizedBox(height: 24),
        const Text(
          "No Orders Yet",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "You haven't placed any orders yet.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              "Start Shopping",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'processing':
        return Icons.sync;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.shopping_bag;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day} ${_getMonthName(date.month)} ${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class OrderItem {
  final int orderId;
  final int productId;
  final String productName;
  final String productThumb;
  final int quantity;
  final double finalPrice;
  final String status;
  final String paidAt;

  OrderItem({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productThumb,
    required this.quantity,
    required this.finalPrice,
    required this.status,
    required this.paidAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productThumb: json['product_thumb'],
      quantity: json['quantity'],
      finalPrice: double.parse(json['final_price']),
      status: json['item_status'],
      paidAt: json['paid_at'],
    );
  }
}

/*class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<List<OrderItem>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = int.parse(prefs.getString("user_id") ?? "0");

    if (userId == 0) {
      debugPrint("User not logged in");
      return;
    }

    setState(() {
      _ordersFuture = ApiService.fetchOrders(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF8F2),
        elevation: 0,
        title: const Text("My Orders", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _ordersFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<OrderItem>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _emptyOrders();
                }

                final orders = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final item = orders[index];
                    return _orderCard(item);
                  },
                );
              },
            ),
    );
  }

  Widget _orderImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 70,
        height: 70,
        color: Colors.white,
      ),
    );
  }

  Widget _orderCard(OrderItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderHistoryScreen(
              orderId: item.orderId,
              productId: item.productId, // ✅ NOW EXISTS
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "${ApiService.productImagePath}${item.productThumb}",
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      "assets/images/placeholder.png",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // 👇 THIS FIXES OVERFLOW
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text("Qty: ${item.quantity}"),
                        const Spacer(),
                        Text(
                          "₹${item.finalPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "You haven’t placed any orders yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Keep Shopping"),
          )
        ],
      ),
    );
  }
}

class OrderItem {
  final int orderId;
  final int productId; // 🔥 ADD THIS
  final String productName;
  final String productThumb;
  final int quantity;
  final double finalPrice;
  final String status;
  final String paidAt;

  OrderItem({
    required this.orderId,
    required this.productId, // 🔥 ADD
    required this.productName,
    required this.productThumb,
    required this.quantity,
    required this.finalPrice,
    required this.status,
    required this.paidAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'],
      productId: json['product_id'],
      // 🔥 MAP IT
      productName: json['product_name'],
      productThumb: json['product_thumb'],
      quantity: json['quantity'],
      finalPrice: double.parse(json['final_price']),
      status: json['item_status'],
      paidAt: json['paid_at'],
    );
  }
}*/

class OrderHistoryScreen extends StatefulWidget {
  final int orderId;
  final int productId;

  const OrderHistoryScreen({
    super.key,
    required this.orderId,
    required this.productId,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<Map<String, dynamic>?> _orderHistoryFuture;
  List<OrderHistoryItem> _historyItems = [];
  Map<String, dynamic> _orderDetails = {};

  @override
  void initState() {
    super.initState();
    // _loadOrderHistory();
    _orderHistoryFuture = _loadOrderHistory();
  }
// Changed return type to Future<Map<String, dynamic>?>
  Future<Map<String, dynamic>?> _loadOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString("user_id");

      if (userIdString == null) {
        debugPrint("User ID not found");
        return null;
      }

      final userId = int.tryParse(userIdString);

      if (userId == null) {
        debugPrint("Invalid user ID");
        return null;
      }

      return await ApiService.fetchOrderHistory(
        userId: userId,
        orderId: widget.orderId,
        productId: widget.productId,
      );
    } catch (e) {
      debugPrint("Error loading order history: $e");
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _orderHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            }

            if (snapshot.hasError) {
              debugPrint("FutureBuilder error: ${snapshot.error}");
              return _buildErrorState();
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return _buildErrorState();
            }

            final response = snapshot.data!;

            // Check if status is "success" (string comparison)
            if (response['status'] != "success" ||
                (response['data'] as List).isEmpty) {
              return _buildNoDataState();
            }

            final data = response['data'][0];
            _orderDetails = data;
            _historyItems = _parseHistoryItems(data);

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Order Status Card
                  _buildOrderStatusCard(data),

                  // Delivery Address
                  _buildDeliveryAddressCard(),

                  // Product Card
                  _buildProductCard(),

                  // Price Details Card
                  _buildPriceDetailsCard(data),

                  // Order Timeline
                  _buildOrderTimelineCard(),

                  // Order Information
                  _buildOrderInfoCard(data),

                  // Need Help Section
                  _buildNeedHelpCard(),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Failed to load order details",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadOrderHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "No order details found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard(Map<String, dynamic> data) {
    final status = data['item_status']?.toString() ?? 'pending';
    final orderDate = data['paid_at']?.toString() ?? '';
    final formattedDate = orderDate.isNotEmpty ? _formatDate(orderDate) : '';

    Color statusColor;
    String statusText;
    String statusIcon;

    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'Delivered';
        statusIcon = '🎉';
        break;
      case 'shipped':
        statusColor = Colors.orange;
        statusText = 'Shipped';
        statusIcon = '🚚';
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusText = 'Processing';
        statusIcon = '⚙️';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
        statusIcon = '⏳';
    }

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order ID: ${widget.orderId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Track',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            if (formattedDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Ordered on $formattedDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _buildProgressIndicator(status),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String status) {
    int currentStep;
    List<String> steps = ['Ordered', 'Shipped', 'Delivered'];

    switch (status.toLowerCase()) {
      case 'delivered':
        currentStep = 3;
        break;
      case 'shipped':
        currentStep = 2;
        break;
      default:
        currentStep = 1;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((entry) {
            int index = entry.key;
            String step = entry.value;
            bool isActive = (index + 1) <= currentStep;

            return Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive ? Icons.check : Icons.circle,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: currentStep / 3,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '123, Main Street, Apartment 4B',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              'City, State - 123456',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Phone: +91 9876543210',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: Colors.grey[200],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected Delivery',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '30 Dec 2025',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Track Package',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    final productName = _orderDetails['product_name']?.toString() ?? 'Product';
    final productThumb = _orderDetails['product_thumb']?.toString() ?? '';
    final quantity = _orderDetails['quantity']?.toString() ?? '1';
    final variant = _orderDetails['variant']?.toString();
    final price =
        double.tryParse(_orderDetails['final_price']?.toString() ?? '0') ?? 0;
    final slug = _orderDetails['slug']?.toString() ?? '';

    return GestureDetector(
      onTap: slug.isNotEmpty
          ? () => _navigateToProductDetail(context, slug)
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: productThumb.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl:
                                  "${ApiService.productImagePath}$productThumb",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.shopping_bag,
                                color: Colors.grey[400],
                              ),
                            )
                          : Icon(
                              Icons.shopping_bag,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        if (variant != null && variant.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Variant: $variant',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Qty: $quantity',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '₹${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '₹${_calculateSavedAmount().toStringAsFixed(2)} saved',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: slug.isNotEmpty
                          ? () => _navigateToProductDetail(context, slug)
                          : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Product',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: slug.isNotEmpty
                          ? () => _navigateToProductDetail(context, slug)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Buy Again',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateSavedAmount() {
    final totalAmount =
        double.tryParse(_orderDetails['total_amount']?.toString() ?? '0') ?? 0;
    final finalPrice =
        double.tryParse(_orderDetails['final_price']?.toString() ?? '0') ?? 0;
    return totalAmount - finalPrice;
  }

  Widget _buildPriceDetailsCard(Map<String, dynamic> data) {
    final totalAmount =
        double.tryParse(data['total_amount']?.toString() ?? '0') ?? 0;
    final discount = double.tryParse(data['discount']?.toString() ?? '0') ?? 0;
    final finalPrice =
        double.tryParse(data['final_price']?.toString() ?? '0') ?? 0;
    final coinsUsed =
        double.tryParse(data['coins_used']?.toString() ?? '0') ?? 0;
    final discountAmount =
        double.tryParse(data['discount_amount']?.toString() ?? '0') ?? 0;
    final couponCode = data['coupon_code']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPriceDetailRow(
                'Total MRP', '₹${totalAmount.toStringAsFixed(2)}'),
            if (discount > 0)
              _buildPriceDetailRow(
                  'Product Discount', '- ₹${discount.toStringAsFixed(2)}',
                  isDiscount: true),
            if (discountAmount > 0)
              _buildPriceDetailRow('Additional Discount',
                  '- ₹${discountAmount.toStringAsFixed(2)}',
                  isDiscount: true),
            if (coinsUsed > 0)
              _buildPriceDetailRow(
                  'Coins Used', '- ₹${coinsUsed.toStringAsFixed(2)}',
                  isDiscount: true),
            if (couponCode != null)
              _buildPriceDetailRow('Coupon Applied', couponCode!),
            _buildPriceDetailRow('Delivery Charges', 'FREE', isDiscount: true),
            Container(
              height: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (finalPrice < totalAmount) ...[
              const SizedBox(height: 8),
              Text(
                'You saved ₹${(totalAmount - finalPrice).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailRow(String label, String value,
      {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.green : Colors.black,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimelineCard() {
    if (_historyItems.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._historyItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == _historyItems.length - 1;
              return _buildTimelineStep(item, isLast);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(OrderHistoryItem item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatStatusText(item.status),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(item.time),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Order ID', '${widget.orderId}'),
            _buildInfoItem('Product ID', '${widget.productId}'),
            if (data['slug'] != null)
              _buildInfoItem('Product Slug', data['slug'].toString()),
            _buildInfoItem('Payment Status',
                data['status']?.toString().toUpperCase() ?? 'PAID'),
            _buildInfoItem('Payment Date',
                _formatDateTime(data['paid_at']?.toString() ?? '')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedHelpCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.help_outline, color: Colors.blue[700]),
                    label: const Text('Help Center'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.chat_outlined, color: Colors.green[700]),
                    label: const Text('Chat Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navigation method
  // Also update the _navigateToProductDetail method (fix the syntax error)
  void _navigateToProductDetail(BuildContext context, String slug) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(slug: slug),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // Helper methods
  List<OrderHistoryItem> _parseHistoryItems(Map<String, dynamic> data) {
    final items = <OrderHistoryItem>[];

    if (data['history_status'] != null) {
      items.add(OrderHistoryItem(
        status: data['history_status'].toString(),
        message: data['history_message']?.toString() ?? 'Payment completed',
        time: data['paid_at']?.toString() ?? '',
      ));
    }

    items.add(OrderHistoryItem(
      status: 'processing',
      message: 'Order is being processed',
      time: data['paid_at']?.toString() ?? '',
    ));

    if (data['item_status']?.toString() == 'shipped' ||
        data['item_status']?.toString() == 'delivered') {
      items.add(OrderHistoryItem(
        status: 'shipped',
        message: 'Order has been shipped',
        time: data['paid_at']?.toString() ?? '',
      ));
    }

    if (data['item_status']?.toString() == 'delivered') {
      items.add(OrderHistoryItem(
        status: 'delivered',
        message: 'Order has been delivered',
        time: data['paid_at']?.toString() ?? '',
      ));
    }

    return items;
  }

  String _formatStatusText(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final date = DateTime.parse(dateTimeString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString; // Fixed: changed dateString to dateTimeString
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class OrderHistoryItem {
  final String status;
  final String message;
  final String time;

  OrderHistoryItem({
    required this.status,
    required this.message,
    required this.time,
  });
}


/*class OrderHistoryScreen extends StatefulWidget {
  final int orderId;
  final int productId;

  const OrderHistoryScreen({
    super.key,
    required this.orderId,
    required this.productId,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<Map<String, dynamic>?> _orderHistoryFuture;
  List<OrderHistoryItem> _historyItems = [];
  Map<String, dynamic> _orderDetails = {};

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = int.parse(prefs.getString("user_id")!);

    _orderHistoryFuture = ApiService.fetchOrderHistory(
      userId: userId,
      orderId: widget.orderId,
      productId: widget.productId,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Order Details", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _orderHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildErrorState();
          }

          final response = snapshot.data!;
          if (!response['status'] || (response['data'] as List).isEmpty) {
            return _buildNoDataState();
          }

          final data = response['data'][0];
          _orderDetails = data;

          // Parse history items
          _historyItems = _parseHistoryItems(data);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Status Header
                _buildOrderStatusHeader(data),

                // Delivery Address (Mock - you can fetch from API if available)
                _buildDeliveryAddress(),

                // Product Details
                _buildProductDetails(),

                // Price Details
                _buildPriceDetails(data),

                // Order Timeline
                _buildOrderTimeline(),

                // Order Information
                _buildOrderInformation(data),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Failed to load order details",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadOrderHistory,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "No order details found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusHeader(Map<String, dynamic> data) {
    final status = data['item_status']?.toString() ?? 'pending';
    final orderDate = data['paid_at']?.toString() ?? '';
    final formattedDate = orderDate.isNotEmpty
        ? _formatDate(orderDate)
        : '';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Delivered';
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        statusText = 'Shipped';
        break;
      case 'processing':
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Processing';
        break;
      default: // pending
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Pending';
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Order ID: ${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          if (formattedDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Order placed on $formattedDate',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _getProgressValue(status),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStep('Ordered', status == 'pending'),
              _buildProgressStep('Shipped', status == 'shipped'),
              _buildProgressStep('Delivered', status == 'delivered'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String text, bool isActive) {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          size: 16,
          color: isActive ? Colors.green : Colors.grey[300],
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.black : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'John Doe',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            '123, Main Street, Apartment 4B',
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            'City, State - 123456',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Phone: +91 9876543210',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Expected by',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '30 Dec 2025',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Track Order',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    final productName = _orderDetails['product_name']?.toString() ?? 'Product';
    final productThumb = _orderDetails['product_thumb']?.toString() ?? '';
    final quantity = _orderDetails['quantity']?.toString() ?? '1';
    final variant = _orderDetails['variant']?.toString();
    final price = double.tryParse(_orderDetails['final_price']?.toString() ?? '0') ?? 0;
    final slug = _orderDetails['slug']?.toString() ?? '';

    return GestureDetector(
      onTap: slug.isNotEmpty
          ? () => _navigateToProductDetail(context, slug)
          : null,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: productThumb.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: "${ApiService.productImagePath}$productThumb",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.shopping_bag,
                        color: Colors.grey[400],
                      ),
                    )
                        : Icon(
                      Icons.shopping_bag,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (variant != null && variant.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Variant: $variant',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Qty: $quantity',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: slug.isNotEmpty
                        ? () => _navigateToProductDetail(context, slug)
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    icon: const Icon(Icons.repeat, size: 16),
                    label: const Text('Buy Again', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    icon: const Icon(Icons.help_outline, size: 16),
                    label: const Text('Help', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Navigation method
  void _navigateToProductDetail(BuildContext context, String slug) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(
              slug: slug,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }



  Widget _buildPriceDetails(Map<String, dynamic> data) {
    final totalAmount = double.tryParse(data['total_amount']?.toString() ?? '0') ?? 0;
    final discount = double.tryParse(data['discount']?.toString() ?? '0') ?? 0;
    final finalPrice = double.tryParse(data['final_price']?.toString() ?? '0') ?? 0;
    final coinsUsed = double.tryParse(data['coins_used']?.toString() ?? '0') ?? 0;
    final couponCode = data['coupon_code']?.toString();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Total MRP', '₹${totalAmount.toStringAsFixed(2)}'),
          if (discount > 0)
            _buildPriceRow('Discount', '- ₹${discount.toStringAsFixed(2)}', isDiscount: true),
          if (coinsUsed > 0)
            _buildPriceRow('Coins Used', '- ₹${coinsUsed.toStringAsFixed(2)}'),
          if (couponCode != null)
            _buildPriceRow('Coupon Applied', couponCode),
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.green : Colors.black,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    if (_historyItems.isEmpty) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Timeline',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._historyItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == _historyItems.length - 1;
            return _buildTimelineTile(item, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(OrderHistoryItem item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.green,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatStatusText(item.status),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInformation(Map<String, dynamic> data) {
    final paymentId = 'PAY_${widget.orderId}';
    final paymentDate = data['paid_at']?.toString() ?? '';
    final orderDate = paymentDate.isNotEmpty ? _formatDate(paymentDate) : '';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Order ID', '${widget.orderId}'),
          _buildInfoRow('Product ID', '${widget.productId}'),
          if (data['slug'] != null)
            _buildInfoRow('Product Slug', data['slug'].toString()),
          _buildInfoRow('Payment ID', paymentId),
          if (orderDate.isNotEmpty)
            _buildInfoRow('Order Date', orderDate),
          if (paymentDate.isNotEmpty)
            _buildInfoRow('Payment Date', _formatDateTime(paymentDate)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<OrderHistoryItem> _parseHistoryItems(Map<String, dynamic> data) {
    final items = <OrderHistoryItem>[];

    // Add payment success entry
    if (data['history_status'] != null) {
      items.add(OrderHistoryItem(
        status: data['history_status'].toString(),
        message: data['history_message']?.toString() ?? 'Payment completed',
        time: data['paid_at']?.toString() ?? '',
      ));
    }

    // Add order processing entry
    items.add(OrderHistoryItem(
      status: 'processing',
      message: 'Order is being processed',
      time: data['paid_at']?.toString() ?? '',
    ));

    // Add shipping entry if applicable
    if (data['item_status']?.toString() == 'shipped' ||
        data['item_status']?.toString() == 'delivered') {
      items.add(OrderHistoryItem(
        status: 'shipped',
        message: 'Order has been shipped',
        time: data['paid_at']?.toString() ?? '',
      ));
    }

    // Add delivery entry if applicable
    if (data['item_status']?.toString() == 'delivered') {
      items.add(OrderHistoryItem(
        status: 'delivered',
        message: 'Order has been delivered',
        time: data['paid_at']?.toString() ?? '',
      ));
    }

    return items;
  }

  String _formatStatusText(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final date = DateTime.parse(dateTimeString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  double _getProgressValue(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0.33;
      case 'processing':
        return 0.33;
      case 'shipped':
        return 0.66;
      case 'delivered':
        return 1.0;
      default:
        return 0.33;
    }
  }
}

class OrderHistoryItem {
  final String status;
  final String message;
  final String time;

  OrderHistoryItem({
    required this.status,
    required this.message,
    required this.time,
  });
}*/
