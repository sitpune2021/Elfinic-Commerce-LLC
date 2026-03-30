import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elfinic_commerce_llc/model/order_history_details_model.dart';
import 'package:elfinic_commerce_llc/providers/order/order_invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ------------------- ORDERS SCREEN -------------------

import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'ProductDetailPage.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<List<OrderItem>>? _ordersFuture;
  List<OrderItem> _allOrders = [];
  List<OrderItem> _filteredOrders = [];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();

    super.dispose();
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (query.isEmpty) {
        setState(() => _filteredOrders = _allOrders);
        return;
      }

      final lowerQuery = query.toLowerCase();

      setState(() {
        _filteredOrders = _allOrders.where((order) {
          return order.orderId.toString().contains(lowerQuery) ||
              order.productName.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:  Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (_isSearching) {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredOrders = _allOrders;
                });
              } else {
                Navigator.pop(context, "dash");
              }
            },
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin:
                      _isSearching ? const Offset(1, 0) : const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _isSearching
                ? _buildAnimatedSearchField()
                : const Text(
                    "My Orders",
                    key: ValueKey("title"),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
          ),
          actions: [
            if (!_isSearching)
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  setState(() => _isSearching = true);
                },
              ),
          ],
          // actions: [
          //   AnimatedSwitcher(
          //     duration: const Duration(milliseconds: 300),
          //     child: _isSearching
          //         ? const SizedBox.shrink()
          //         : IconButton(
          //             key: const ValueKey("search"),
          //             icon: const Icon(Icons.search, color: Colors.black),
          //             onPressed: () {
          //               setState(() => _isSearching = true);
          //             },
          //           ),
          //   ),
          // ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ),
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
                  _allOrders.sort((a, b) {
                    return DateTime.parse(b.paidAt)
                        .compareTo(DateTime.parse(a.paidAt));
                  });
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

//search widget
  Widget _buildAnimatedSearchField() {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(
        begin: const Offset(1.2, 0),
        end: Offset.zero,
      ),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx * 250, 0),
          child: child,
        );
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: TextField(
          cursorColor: Colors.grey,
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          textAlignVertical: TextAlignVertical.center, // 🔥 KEY FIX
          decoration: InputDecoration(
            isDense: true, // 🔥 KEY FIX
            hintText: 'Search Order ID or Product name',
            hintStyle: const TextStyle(fontSize: 14),
            border: InputBorder.none,

            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredOrders = _allOrders;
                });
              },
            ),
          ),
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
              color: Colors.grey.withValues(alpha: 0.1),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
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
                        imageUrl:
                            "${ApiService.productImagePath}${item.productThumb}",
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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
                  // if (item.status.toLowerCase() == 'delivered')
                  //   Expanded(
                  //     child: ElevatedButton(
                  //       onPressed: () {},
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.orange,
                  //         foregroundColor: Colors.white,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //       ),
                  //       child: const Text(
                  //         'Rate',
                  //         style: TextStyle(fontSize: 12),
                  //       ),
                  //     ),
                  //   ),
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
        SizedBox(
          height: 200,
          child: Image.asset(
            'assets/images/GirlholdingEmptyShoppingCart.jpeg',
            height: 200,
            width: 200,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
            },
          )

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
              Navigator.pop(context, "dash");
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderInvoiceProvider>().loadOrderHistorysDetails(
            orderId: widget.orderId,
            productId: widget.productId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        bottom: true,
        // child: FutureBuilder<Map<String, dynamic>?>(
        //   future: _orderHistoryFuture,
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return _buildShimmerLoading();
        //     }

        //     if (snapshot.hasError) {
        //       debugPrint("FutureBuilder error: ${snapshot.error}");
        //       return _buildErrorState();
        //     }

        //     if (!snapshot.hasData || snapshot.data == null) {
        //       return _buildErrorState();
        //     }

        //     final response = snapshot.data!;

        //     // Check if status is "success" (string comparison)
        //     if (response['status'] != "success" ||
        //         (response['data'] as List).isEmpty) {
        //       return _buildNoDataState();
        //     }

        //     final data = response['data'][0];
        //     _orderDetails = data;
        //     _historyItems = _parseHistoryItems(data);
        child: Consumer<OrderInvoiceProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return _buildShimmerLoading();
            }

            final order = provider.order;
            if (order == null) {
              return _buildNoDataState();
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Order Status Card
                  // _buildOrderStatusCard(data),

                  // // Delivery Address
                  // _buildDeliveryAddressCard(context),

                  // Product Card
                  _buildProductCardFromModel(order),

                  // Price Details Card
                  _buildPriceDetailsCardFromModel(order),

                  // Order Timeline STEPPER
                  _buildOrderTimelineCard(provider.history),

                  // Delivery Address
                  _buildDeliveryAddressCard(context),

                  // Order Information
                  _buildOrderInfoCardFromModel(order),

                  // Invoice Download
                  _buildInvoiceDownloadCard(context),

                  // Need Help Section
                  // _buildNeedHelpCard(),

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

  // Widget _buildErrorState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
  //         const SizedBox(height: 16),
  //         const Text(
  //           "Failed to load order details",
  //           style: TextStyle(fontSize: 16, color: Colors.grey),
  //         ),
  //         const SizedBox(height: 8),
  //         ElevatedButton(
  //           onPressed: _loadOrderHistory,
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.blue,
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: const Text("Retry"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
            color: Colors.grey.withValues(alpha: 0.1),
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
                    color: statusColor.withValues(alpha: 0.1),
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
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                _showOrderHistoryDialog(context);
              },
              child: Text(
                'See All Updates  >',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
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

  Widget _buildDeliveryAddressCard(BuildContext context) {
    final provider = context.watch<OrderInvoiceProvider>();
    final address = provider.address;

    if (address == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.name ?? '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '${address.addressLine1 ?? ''}, ${address.addressLine2 ?? ''}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              '${address.city ?? ''}, ${address.state ?? ''}, ${address.country ?? ''} - ${address.postalCode ?? ''}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: ${address.phone ?? ''}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              address.type ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // tap outside to close
      builder: (context) {
        final width = MediaQuery.of(context).size.width;

        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: width > 600 ? 100 : 16,
            vertical: 24,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔝 Header with title & close icon
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Order History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // 📜 History list
                SizedBox(
                  height: width > 600 ? 400 : 300,
                  child: _buildOrderHistory(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderHistory(BuildContext context) {
    final history = context.watch<OrderInvoiceProvider>().history;

    if (history.isEmpty) return const SizedBox();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(item.historyStatus ?? ''),
          subtitle: Text(item.historyMessage ?? ''),
          trailing: Text(
            item.createdAt ?? '',
            style: const TextStyle(fontSize: 11),
          ),
        );
      },
    );
  }

  Widget _buildProductCardFromModel(Datum order) {
    final productName = order.productName ?? 'Product';
    final productThumb = order.productThumb ?? '';
    final quantity = order.quantity?.toString() ?? '1';
    final variant = order.variantName;
    final price = double.tryParse(order.finalPrice ?? '0') ?? 0.0;
    final slug = order.slug ?? '';

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
              color: Colors.grey.withValues(alpha: 0.1),
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
                  /// Product Image
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
                              imageUrl: buildProductImageUrl(productThumb),
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey[200],
                              ),
                              errorWidget: (_, __, ___) => Icon(
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

                  /// Product Info
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
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Qty: $quantity',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '₹${_calculateSavedAmountFromModel(order).toStringAsFixed(2)} saved',
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

              /// Buttons
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

  String buildProductImageUrl(String path) {
    if (path.isEmpty) return '';

    final cleanPath = path.trim().replaceFirst(RegExp(r'^/+'), '');

    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }

    return 'https://admin.elfinic.com/$cleanPath';
  }

  double _calculateSavedAmountFromModel(Datum order) {
    final totalAmount = double.tryParse(order.totalAmount ?? '0') ?? 0.0;
    final finalPrice = double.tryParse(order.finalPrice ?? '0') ?? 0.0;
    return totalAmount - finalPrice;
  }

  Widget _buildPriceDetailsCardFromModel(Datum order) {
    final totalAmount = double.tryParse(order.totalAmount ?? '0') ?? 0.0;
    final discount = double.tryParse(order.discount ?? '0') ?? 0.0;
    final finalPrice = double.tryParse(order.finalPrice ?? '0') ?? 0.0;
    final coinsUsed = double.tryParse(order.coinsUsed ?? '0') ?? 0.0;
    final discountAmount = double.tryParse(order.discountAmount ?? '0') ?? 0.0;
    final couponCode = order.couponCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              'Total MRP',
              '₹${totalAmount.toStringAsFixed(2)}',
            ),
            if (discount > 0)
              _buildPriceDetailRow(
                'Product Discount',
                '- ₹${discount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            if (discountAmount > 0)
              _buildPriceDetailRow(
                'Additional Discount',
                '- ₹${discountAmount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            if (coinsUsed > 0)
              _buildPriceDetailRow(
                'Coins Used',
                '- ₹${coinsUsed.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            if (couponCode != null && couponCode.isNotEmpty)
              _buildPriceDetailRow('Coupon Applied', couponCode),
            _buildPriceDetailRow(
              'Delivery Charges',
              'FREE',
              isDiscount: true,
            ),
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
            if (finalPrice < totalAmount)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'You saved ₹${(totalAmount - finalPrice).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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

  Widget _buildOrderTimelineCard(List<History> historyItems) {
    if (historyItems.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Timeline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...historyItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == historyItems.length - 1;
            return _buildTimelineStep(item, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(History item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Left step indicator
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: Colors.grey.shade300,
              ),
          ],
        ),

        const SizedBox(width: 12),

        /// Right content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatStatusText(item.historyStatus ?? ''),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  convertAsciiEmoji(cleanMessage(item.historyMessage ?? '')),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(item.createdAt ?? ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String convertAsciiEmoji(String text) {
    return text
        .replaceAll(':-)', '😊')
        .replaceAll(':)', '😊')
        .replaceAll(':-(', '😞')
        .replaceAll(':(', '😞');
  }

  String cleanMessage(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  }

  Widget _buildOrderInfoCardFromModel(Datum order) {
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
            _buildInfoItem('Order ID', order.orderId?.toString() ?? ''),
            _buildInfoItem('Order Number', order.orderNumber ?? ''),
            _buildInfoItem('Product ID', order.productId?.toString() ?? ''),
            if (order.vendorName != null && order.vendorName!.trim().isNotEmpty)
              _buildInfoItem('Vendor', order.vendorName!),
            _buildInfoItem(
              'Payment Status',
              (order.paymentStatus ?? 'paid').toUpperCase(),
            ),
            if (order.paidAt != null)
              _buildInfoItem(
                'Payment Date',
                _formatDateTime(order.paidAt!.toIso8601String()),
              ),
            if (order.quantity != null)
              _buildInfoItem('Quantity', order.quantity.toString()),
            if (order.variantName != null && order.variantName!.isNotEmpty)
              _buildInfoItem('Variant', order.variantName!),
          ],
        ),
      ),
    );
  }

  //
  Widget _buildInvoiceDownloadCard(BuildContext context) {
    return Consumer<OrderInvoiceProvider>(
      builder: (_, provider, __) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Invoice',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Download & preview invoice',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: provider.downloading
                      ? null
                      : () {
                          provider.downloadInvoice(
                            context: context,
                            orderId: widget.orderId,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: provider.downloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Download'),
                ),
              ],
            ),
          ),
        );
      },
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
            color: Colors.grey.withValues(alpha: 0.1),
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
