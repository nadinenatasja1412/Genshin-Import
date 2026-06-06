import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/appTheme.dart';
import '../../services/cartServices.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  String _formatPrice(double price) => _currencyFormatter.format(price);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cart.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : cart.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty.',
                style: AppTextStyles.bodyLarge,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        color: AppColors.darkCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.weapon.name,
                                      style: AppTextStyles.titleLarge,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${item.weapon.price.toStringAsFixed(0)}',
                                    style: AppTextStyles.price.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.weapon.type,
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: item.quantity > 1
                                        ? () => cart.updateQuantity(
                                            item.id,
                                            item.quantity - 1,
                                          )
                                        : null,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    onTap: item.quantity < item.weapon.stock
                                        ? () => cart.updateQuantity(
                                            item.id,
                                            item.quantity + 1,
                                          )
                                        : null,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () => cart.removeItem(item.id),
                                  ),
                                ],
                              ),
                              Text(
                                'Subtotal: ${_formatPrice(item.totalPrice)}',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.goldDark.withAlpha(
                          (0.2 * 255).round(),
                        ),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextStyles.titleLarge),
                          Text(
                            _formatPrice(cart.totalPrice),
                            style: AppTextStyles.price.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: cart.loading
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await cart.checkout();
                                if (!mounted) return;
                                if (cart.error != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(cart.error!),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Checkout completed!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Checkout (${cart.totalQuantity} items)',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: onTap == null ? AppColors.textSecondary : AppColors.gold,
      ),
      onPressed: onTap,
    );
  }
}
