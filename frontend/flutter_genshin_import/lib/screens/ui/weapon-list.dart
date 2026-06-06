import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/appTheme.dart';
import '../../services/authServices.dart';
import '../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/apiServices.dart';
import '../../services/cartServices.dart';
import './weapon-detail.dart';
import './weapon-form.dart';
import './order-history.dart';
import './cart.dart';
import './login.dart';

class WeaponListScreen extends StatefulWidget {
  const WeaponListScreen({super.key});

  @override
  State<WeaponListScreen> createState() => _WeaponListScreenState();
}

class _WeaponListScreenState extends State<WeaponListScreen> {
  List<Weapon> _weapons = [];
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();
  String _selectedType = '';

  static const List<String> _types = [
    '',
    'Sword',
    'Claymore',
    'Polearm',
    'Bow',
    'Catalyst',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getWeapons(
        search: _searchCtrl.text.trim(),
        type: _selectedType,
      );
      setState(() {
        _weapons = data;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load weapons. Check server connection.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteWeapon(Weapon weapon) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Weapon', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to delete "${weapon.name}"?\nThis action cannot be undone.',
          style: AppTextStyles.bodyLarge,
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiService.deleteWeapon(weapon.id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weapon deleted successfully.')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final isAdmin = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const GenshinTitle(text: 'GENSHIN IMPORT'),
        actions: [
          if (!isAdmin) ...[
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cart.totalQuantity > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.totalQuantity}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Cart',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
                if (mounted) {
                  context.read<CartProvider>().loadCart();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'My Orders',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeaponFormScreen()),
                );
                _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Weapon'),
            )
          : null,

      body: Column(
        children: [
          // User welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.darkCard,
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: AppColors.gold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome, ${auth.user?.name ?? 'Traveler'}  •  ${isAdmin ? "Admin" : "User"}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search + Filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search weapons…',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.gold,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _load();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 8),
                // Type filter dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldDark.withOpacity(0.4),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      dropdownColor: AppColors.darkCard,
                      style: AppTextStyles.bodyLarge,
                      items: _types
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.isEmpty ? 'All' : t),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedType = v ?? '');
                        _load();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Type chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: _types.map((t) {
                final label = t.isEmpty ? 'All' : t;
                final selected = _selectedType == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedType = t);
                      _load();
                    },
                    selectedColor: AppColors.gold.withOpacity(0.25),
                    checkmarkColor: AppColors.gold,
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : _error != null
                ? ErrorView(message: _error!, onRetry: _load)
                : _weapons.isEmpty
                ? Center(
                    child: Text(
                      'No weapons found.',
                      style: AppTextStyles.bodyLarge,
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.gold,
                    onRefresh: _load,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                      itemCount: _weapons.length,
                      itemBuilder: (ctx, i) {
                        final weapon = _weapons[i];
                        return WeaponCard(
                          weapon: weapon,
                          isAdmin: isAdmin,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WeaponDetailScreen(weapon: weapon),
                              ),
                            );
                            _load();
                          },
                          onEdit: isAdmin
                              ? () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          WeaponFormScreen(weapon: weapon),
                                    ),
                                  );
                                  _load();
                                }
                              : null,
                          onDelete: isAdmin
                              ? () => _deleteWeapon(weapon)
                              : null,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
