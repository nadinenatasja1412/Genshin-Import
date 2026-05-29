import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/appTheme.dart';
import '../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/apiServices.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _orders = await ApiService.getMyOrders();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Could not load orders.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatPrice(double price) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(price);

  String _formatDate(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GenshinTitle(text: 'MY ORDERS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : _error != null
          ? ErrorView(message: _error!, onRetry: _load)
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: 16),
                  Text('No orders yet.', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Buy a weapon to see your history here.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.gold,
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (ctx, i) {
                  final order = _orders[i];
                  return _OrderCard(
                    order: order,
                    formatPrice: _formatPrice,
                    formatDate: _formatDate,
                  );
                },
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.formatPrice,
    required this.formatDate,
  });
  final Order order;
  final String Function(double) formatPrice;
  final String Function(DateTime) formatDate;

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Weapon image / icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.darkSurface,
                child: order.weaponImageUrl != null
                    ? Image.network(
                        order.weaponImageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.shield, color: AppColors.goldDark),
                      )
                    : const Icon(Icons.shield, color: AppColors.goldDark),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.weaponName,
                          style: AppTextStyles.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(order.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  WeaponTypeChip(order.weaponType, small: true),
                  const SizedBox(height: 6),
                  Text(
                    'Qty: ${order.quantity}  •  ${formatPrice(order.totalPrice)}',
                    style: AppTextStyles.price.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(order.orderedAt),
                    style: AppTextStyles.caption,
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
