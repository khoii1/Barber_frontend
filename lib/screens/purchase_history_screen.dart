import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/payment_provider.dart';
import '../models/payment.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  String _selectedFilter = 'all'; // all, pending, completed, cancelled

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).loadMyPayments();
    });
  }

  String _formatDate(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(dateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return dateFormat.format(dateTime);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.pending;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  List<Payment> _getFilteredPayments(PaymentProvider provider) {
    switch (_selectedFilter) {
      case 'pending':
        return provider.pendingPayments;
      case 'completed':
        return provider.completedPayments;
      case 'cancelled':
        return provider.cancelledPayments;
      default:
        return provider.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Lịch sử mua hàng'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PaymentProvider>(context, listen: false).loadMyPayments();
            },
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, _) {
          if (paymentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
              ),
            );
          }

          if (paymentProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: ${paymentProvider.errorMessage}',
                    style: const TextStyle(color: _darkGreen),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      paymentProvider.loadMyPayments();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final payments = _getFilteredPayments(paymentProvider);

          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'all'
                        ? 'Chưa có đơn hàng nào'
                        : 'Không có đơn hàng nào',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter buttons
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tất cả', paymentProvider.payments.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('pending', 'Chờ thanh toán', paymentProvider.pendingPayments.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('completed', 'Đã thanh toán', paymentProvider.completedPayments.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('cancelled', 'Đã hủy', paymentProvider.cancelledPayments.length),
                    ],
                  ),
                ),
              ),
              // Payments list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => paymentProvider.loadMyPayments(),
                  color: _darkGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return _buildPaymentCard(payment);
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

  Widget _buildFilterChip(String filter, String label, int count) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: _darkGreen.withOpacity(0.2),
      checkmarkColor: _darkGreen,
      labelStyle: TextStyle(
        color: isSelected ? _darkGreen : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final statusColor = _getStatusColor(payment.status);
    final productImageUrl = payment.product?['imageUrl'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(payment.status),
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      payment.statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(payment.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Product info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                if (productImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: productImageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 60,
                        color: _darkGreen.withOpacity(0.1),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: _darkGreen,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        color: _darkGreen.withOpacity(0.1),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _darkGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: _darkGreen,
                    ),
                  ),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.productNameSnapshot,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Số lượng: ${payment.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phương thức: ${payment.paymentMethodText}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Total amount
                Text(
                  payment.formattedPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),
              ],
            ),
            // Completed info
            if (payment.status == 'COMPLETED' && payment.completedAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đã thanh toán: ${_formatDateTime(payment.completedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Note
            if (payment.note != null && payment.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ghi chú: ${payment.note}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

