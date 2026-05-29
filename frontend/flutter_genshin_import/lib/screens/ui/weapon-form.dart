import 'package:flutter/material.dart';
import '../../theme/appTheme.dart';
import '../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/apiServices.dart';

class WeaponFormScreen extends StatefulWidget {
  const WeaponFormScreen({super.key, this.weapon});
  final Weapon? weapon; // null → create mode

  @override
  State<WeaponFormScreen> createState() => _WeaponFormScreenState();
}

class _WeaponFormScreenState extends State<WeaponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  String _selectedType = 'Sword';
  bool _saving = false;

  static const List<String> _weaponTypes = [
    'Sword',
    'Claymore',
    'Polearm',
    'Bow',
    'Catalyst',
  ];

  bool get _isEdit => widget.weapon != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final w = widget.weapon!;
      _nameCtrl.text = w.name;
      _descCtrl.text = w.description;
      _stockCtrl.text = '${w.stock}';
      _priceCtrl.text = '${w.price.toStringAsFixed(0)}';
      _imageCtrl.text = w.imageUrl ?? '';
      _selectedType = w.type;
    }
  }

  // ── Validations ──────────────────────────────────────────────
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Weapon name is required.';
    if (v.trim().length < 3) return 'Name must be at least 3 characters.';
    return null;
  }

  String? _validateDescription(String? v) {
    if (v == null || v.trim().isEmpty) return 'Description is required.';
    if (v.trim().length < 10)
      return 'Description must be at least 10 characters.';
    return null;
  }

  String? _validateStock(String? v) {
    if (v == null || v.trim().isEmpty) return 'Stock is required.';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Stock must be a whole number.';
    if (n < 0) return 'Stock cannot be negative.';
    return null;
  }

  String? _validatePrice(String? v) {
    if (v == null || v.trim().isEmpty) return 'Price is required.';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Price must be a valid number.';
    if (n <= 0) return 'Price must be greater than zero.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'type': _selectedType,
        'description': _descCtrl.text.trim(),
        'stock': int.parse(_stockCtrl.text.trim()),
        'price': double.parse(_priceCtrl.text.trim()),
        'image_url': _imageCtrl.text.trim().isEmpty
            ? null
            : _imageCtrl.text.trim(),
      };

      if (_isEdit) {
        await ApiService.updateWeapon(widget.weapon!.id, payload);
      } else {
        await ApiService.createWeapon(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Weapon updated!' : 'Weapon added!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GenshinTitle(text: _isEdit ? 'EDIT WEAPON' : 'ADD WEAPON'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview banner
                if (_imageCtrl.text.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _imageCtrl.text,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),

                const SizedBox(height: 8),

                // Section header
                _SectionLabel('Weapon Info'),

                // Name
                GenshinTextField(
                  controller: _nameCtrl,
                  label: 'Weapon Name',
                  hint: 'e.g. Skyward Harp',
                  icon: Icons.shield,
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                // Type dropdown
                _TypeSelector(
                  selected: _selectedType,
                  types: _weaponTypes,
                  onChanged: (t) => setState(() => _selectedType = t),
                ),
                const SizedBox(height: 16),

                // Description
                GenshinTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Describe this weapon lore and power',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: _validateDescription,
                ),
                const SizedBox(height: 24),

                _SectionLabel('Inventory & Pricing'),

                // Stock
                GenshinTextField(
                  controller: _stockCtrl,
                  label: 'Stock',
                  hint: '0',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  validator: _validateStock,
                ),
                const SizedBox(height: 16),

                // Price
                GenshinTextField(
                  controller: _priceCtrl,
                  label: 'Price (Rp)',
                  hint: '450000',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: _validatePrice,
                ),
                const SizedBox(height: 24),

                _SectionLabel('Media'),

                // Image URL
                GenshinTextField(
                  controller: _imageCtrl,
                  label: 'Image URL (optional)',
                  hint: 'https://example.com/weapon.png',
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: Icon(_isEdit ? Icons.save : Icons.add, size: 20),
                  label: Text(_isEdit ? 'SAVE CHANGES' : 'ADD WEAPON'),
                ),
                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.gold,
          letterSpacing: 2,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.selected,
    required this.types,
    required this.onChanged,
  });

  final String selected;
  final List<String> types;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weapon Type', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((t) {
            final isSelected = t == selected;
            final color = AppColors.weaponTypeColors[t] ?? AppColors.gold;
            return GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.25)
                      : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : AppColors.goldDark.withOpacity(0.4),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
