import 'package:flutter/material.dart';
import '../../theme/appTheme.dart';
import '../../models/models.dart';

// ─────────────────────────────────────────────────────────────────
// 1. GoldDivider
// ─────────────────────────────────────────────────────────────────
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, this.indent = 16});
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.goldDark.withOpacity(0.4),
      thickness: 1,
      indent: indent,
      endIndent: indent,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 2. WeaponTypeChip
// ─────────────────────────────────────────────────────────────────
class WeaponTypeChip extends StatelessWidget {
  const WeaponTypeChip(this.type, {super.key, this.small = false});
  final String type;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.weaponTypeColors[type] ?? AppColors.gold;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 3. LoadingOverlay
// ─────────────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 4. GenshinTextField
// ─────────────────────────────────────────────────────────────────
class GenshinTextField extends StatelessWidget {
  const GenshinTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 5. WeaponCard — used in grid lists
// ─────────────────────────────────────────────────────────────────
class WeaponCard extends StatelessWidget {
  const WeaponCard({
    super.key,
    required this.weapon,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isAdmin = false,
  });

  final Weapon weapon;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: weapon.imageUrl != null
                    ? Image.network(
                        weapon.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeaponTypeChip(weapon.type, small: true),
                  const SizedBox(height: 4),
                  Text(
                    weapon.name,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${_formatPrice(weapon.price)}',
                        style: AppTextStyles.price.copyWith(fontSize: 13),
                      ),
                      _stockBadge(),
                    ],
                  ),
                ],
              ),
            ),

            // Admin actions
            if (isAdmin) ...[
              const GoldDivider(indent: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.gold,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: AppColors.error,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.darkSurface,
      child: const Center(
        child: Icon(Icons.shield, size: 48, color: AppColors.goldDark),
      ),
    );
  }

  Widget _stockBadge() {
    final color = weapon.stock == 0
        ? AppColors.error
        : weapon.stock < 5
        ? AppColors.warning
        : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        weapon.stock == 0 ? 'Out' : '${weapon.stock}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

// ─────────────────────────────────────────────────────────────────
// 6. ErrorView
// ─────────────────────────────────────────────────────────────────
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 7. GoldAppBar title widget
// ─────────────────────────────────────────────────────────────────
class GenshinTitle extends StatelessWidget {
  const GenshinTitle({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
      ).createShader(bounds),
      child: Text(
        text,
        style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
      ),
    );
  }
}
