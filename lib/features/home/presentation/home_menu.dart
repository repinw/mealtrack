import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/shoppinglist/presentation/shopping_list_page.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scan_options_bottom_sheet.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class HomeMenu extends ConsumerStatefulWidget {
  const HomeMenu({super.key});

  @override
  ConsumerState<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends ConsumerState<HomeMenu> {
  int _selectedIndex = 0;

  void _onFabPressed() {
    if (_selectedIndex == 0) {
      ScanOptionsBottomSheet.show(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add Item - Not implemented yet')),
      );
    }
  }

  Widget _buildFabIcon() {
    final scannerState = ref.watch(scannerViewModelProvider);
    if (_selectedIndex == 0) {
      if (scannerState.isLoading) {
        return const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        );
      }
      return const Icon(Icons.center_focus_weak, color: Colors.white);
    } else {
      return const Icon(Icons.add, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      const InventoryPage(title: 'MealTrack'),
      const ShoppingListPage(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          width: 48,
          height: 48,
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            onPressed: _onFabPressed,
            child: _buildFabIcon(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  label: l10n.inventory,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.shopping_bag_outlined,
                  selectedIcon: Icons.shopping_bag,
                  label: l10n.shoppinglist,
                  isComingSoon: true,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.local_fire_department_outlined,
                  selectedIcon: Icons.local_fire_department,
                  label: 'Kalorien',
                  isComingSoon: true,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.bar_chart_outlined,
                  selectedIcon: Icons.bar_chart,
                  label: 'Statistik',
                  isComingSoon: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool isComingSoon = false,
  }) {
    if (isComingSoon) {
      return InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diese Funktion ist noch in Arbeit 🚧'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Opacity(
            opacity: 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.grey),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isSelected = _selectedIndex == index;
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
