import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/appTheme.dart';
import '../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/apiServices.dart';
import '../../services/authServices.dart';
import '../../services/cartServices.dart';

class WeaponDetailScreen extends StatefulWidget {
  const WeaponDetailScreen({super.key, required this.weapon});
  final Weapon weapon;

  @override
  State<WeaponDetailScreen> createState() => _WeaponDetailScreenState();
}

class _WeaponDetailScreenState extends State<WeaponDetailScreen> {
  int _quantity = 1;
  bool _buying = false;
  late Weapon _weapon;

  @override
  void initState() {
    super.initState();
    _weapon = widget.weapon;
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  Future<void> _buy() async {
    // Validation: quantity must be at least 1
    if (_quantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity must be at least 1.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    // Validation: quantity must not exceed stock
    if (_quantity > _weapon.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${_weapon.stock} in stock.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Purchase', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_weapon.name, style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text('Quantity: $_quantity', style: AppTextStyles.bodyLarge),
            Text(
              'Total: ${_formatPrice(_weapon.price * _quantity)}',
              style: AppTextStyles.price,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Buy Now'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _buying = true);
    try {
      final order = await ApiService.placeOrder(_weapon.id, _quantity);
      if (!mounted) return;
      // Refresh weapon detail to update stock
      final updated = await ApiService.getWeaponById(_weapon.id);
      setState(() {
        _weapon = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #${order.id} placed! Total: ${_formatPrice(order.totalPrice)}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final typeColor =
        AppColors.weaponTypeColors[_weapon.type] ?? AppColors.gold;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar with weapon image ─────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.darkCard,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A1628), AppColors.darkCard],
                  ),
                ),
                child: _weapon.imageUrl != null
                    ? Image.network(
                        _weapon.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shield,
                          size: 100,
                          color: AppColors.goldDark,
                        ),
                      )
                    : const Icon(
                        Icons.shield,
                        size: 100,
                        color: AppColors.goldDark,
                      ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + Stock row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WeaponTypeChip(_weapon.type),
                      _StockBadge(stock: _weapon.stock),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(_weapon.name, style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    _formatPrice(_weapon.price),
                    style: AppTextStyles.price.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 20),

                  // Divider with label
                  Row(
                    children: [
                      Text(
                        'Description',
                        style: AppTextStyles.caption.copyWith(
                          color: typeColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: GoldDivider(indent: 0)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_weapon.description, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 32),

                  // Stats mini-card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.goldDark.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'Type', value: _weapon.type),
                        _StatItem(label: 'Stock', value: '${_weapon.stock}'),
                        _StatItem(
                          label: 'Price / pc',
                          value: _formatPrice(_weapon.price),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buy section (user only)
                  if (!isAdmin && _weapon.stock > 0) ...[
                    Text(
                      'Purchase',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quantity selector
                    Row(
                      children: [
                        Text('Quantity:', style: AppTextStyles.bodyLarge),
                        const Spacer(),
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_quantity',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: () {
                            if (_quantity < _weapon.stock) {
                              setState(() => _quantity++);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: AppTextStyles.bodyLarge),
                        Text(
                          _formatPrice(_weapon.price * _quantity),
                          style: AppTextStyles.price.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Buy button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _buying ? null : _buy,
                        icon: _buying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.deepNavy,
                                ),
                              )
                            : const Icon(Icons.shopping_cart, size: 20),
                        label: Text(_buying ? 'Processing…' : 'BUY NOW'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _buying
                            ? null
                            : () async {
                                final cart = context.read<CartProvider>();
                                await cart.addToCart(_weapon, _quantity);
                                if (cart.error != null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(cart.error!),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart.'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        label: const Text('ADD TO CART'),
                      ),
                    ),
                  ],

                  if (!isAdmin && _weapon.stock == 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.4),
                        ),
                      ),
                      child: const Text(
                        'Out of Stock',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleMedium, maxLines: 1),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gold),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.gold, size: 18),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final color = stock == 0
        ? AppColors.error
        : stock < 5
        ? AppColors.warning
        : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        stock == 0 ? 'Out of Stock' : 'Stock: $stock',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
